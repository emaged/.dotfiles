#!/usr/bin/env python3
"""Private Unix-socket relay for forwarded agents; never stores or parses keys."""

import argparse
import asyncio
import contextlib
import fcntl
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import stat
import sys
import tempfile


class Routing:
    def __init__(self, runtime=None, peers=None, home=None):
        self.home = Path(home or Path.home())
        runtime = Path(runtime or os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
        self.root = runtime / "ssh-agent-routing"
        self.peers = peers if peers is not None else json.loads(
            Path(__file__).resolve().with_name("agent-peers.json").read_text()
        )
        self.local = self.home / ".1password/agent.sock"

    def prepare(self):
        for directory in (self.root, self.root / "connections"):
            directory.mkdir(mode=0o700, exist_ok=True)
            info = directory.lstat()
            if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.getuid() or info.st_mode & 0o077:
                raise ValueError(f"Expected a private, user-owned directory: {directory}")

    def socket_info(self, path):
        path = Path(path)
        resolved = path.resolve()
        if not path.is_absolute() or resolved == self.local.resolve() or resolved.is_relative_to(self.root):
            raise ValueError("Refusing a local or relay socket as a forwarded agent")
        # Reject symlinks, other users' sockets, and accessible-to-others sockets.
        info = path.lstat()
        if not stat.S_ISSOCK(info.st_mode) or info.st_uid != os.getuid() or info.st_mode & 0o077:
            raise ValueError("Expected a private, user-owned forwarded socket")
        if path == self.root.parent / "ssh-agent.socket":
            raise ValueError("Refusing the local system agent")
        return info

    @contextlib.contextmanager
    def registry_lock(self):
        self.prepare()
        fd = os.open(self.root / "registry.lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
        try:
            fcntl.flock(fd, fcntl.LOCK_EX)
            yield
        finally:
            os.close(fd)

    def register(self, connection, path):
        fields = connection.split()
        if len(fields) != 4:
            raise ValueError("No incoming SSH connection")
        address = ipaddress.ip_address(fields[0])
        peer = next((name for name, addresses in self.peers.items()
                     if address in map(ipaddress.ip_address, addresses)), None)
        if peer is None:
            raise ValueError("SSH origin is not one of the configured computers")
        info = self.socket_info(path)
        record = {"peer": peer, "socket": str(path), "device": info.st_dev, "inode": info.st_ino}
        name = hashlib.sha256(str(path).encode()).hexdigest()
        destination = self.root / "connections" / f"{peer}-{name}.json"
        with self.registry_lock():
            # Do not let subshells reorder existing connections.
            if destination.exists() and self.read_record(destination) == record:
                return
            fd, temporary = tempfile.mkstemp(prefix=".register-", dir=destination.parent)
            try:
                with os.fdopen(fd, "w") as output:
                    json.dump(record, output)
                    output.write("\n")
                os.replace(temporary, destination)
            finally:
                with contextlib.suppress(FileNotFoundError):
                    os.unlink(temporary)
            self._candidates(peer)  # Prune dead records without racing registrations.

    @staticmethod
    def read_record(path):
        fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
        with os.fdopen(fd) as source:
            info = os.fstat(source.fileno())
            if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_mode & 0o077:
                raise ValueError("Unsafe connection record")
            if info.st_size > 4096:
                raise ValueError("Oversized connection record")
            return json.load(source)

    def candidates(self, peer):
        with self.registry_lock():
            return self._candidates(peer)

    def _candidates(self, peer):
        found = []
        for path in (self.root / "connections").glob(f"{peer}-*.json"):
            try:
                record = self.read_record(path)
                if record["peer"] != peer:
                    raise ValueError("Mismatched source")
                info = self.socket_info(record["socket"])
                if (info.st_dev, info.st_ino) != (record["device"], record["inode"]):
                    raise ValueError("Forwarded socket was replaced")
                found.append((path.stat().st_mtime_ns, record["socket"]))
            except (OSError, ValueError, KeyError, TypeError):
                with contextlib.suppress(FileNotFoundError):
                    path.unlink()
        return [path for _, path in sorted(found, reverse=True)]

    async def connect(self, peer):
        # Only try connections from this source. Never fall back to local 1Password.
        for path in self.candidates(peer):
            try:
                reader, writer = await asyncio.wait_for(asyncio.open_unix_connection(path), 1)
                return reader, writer, path
            except (OSError, TimeoutError):
                continue
        raise ConnectionError(f"No forwarded agent available from {peer}")

    async def relay(self, peer, reader, writer):
        backend = None
        tasks = []
        try:
            remote_reader, backend, _ = await self.connect(peer)

            async def copy(source, destination):
                while data := await source.read(65536):
                    destination.write(data)
                    await destination.drain()
                if destination.can_write_eof():
                    destination.write_eof()

            tasks = [asyncio.create_task(copy(reader, backend)),
                     asyncio.create_task(copy(remote_reader, writer))]
            await asyncio.gather(*tasks)
        except (OSError, ConnectionError) as error:
            print(f"{peer}: {error}", file=sys.stderr, flush=True)
        finally:
            for task in tasks:
                task.cancel()
            await asyncio.gather(*tasks, return_exceptions=True)
            for stream in (writer, backend):
                if stream is not None:
                    stream.close()
                    with contextlib.suppress(OSError):
                        await stream.wait_closed()

    async def serve(self):
        self.prepare()
        lock_fd = os.open(self.root / "service.lock", os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
        servers = []
        bound = []
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            for peer in self.peers:
                path = self.root / f"{peer}.sock"
                if path.exists() or path.is_symlink():
                    info = path.lstat()
                    if not stat.S_ISSOCK(info.st_mode) or info.st_uid != os.getuid():
                        raise ValueError(f"Refusing to replace {path}")
                    path.unlink()
                server = await asyncio.start_unix_server(
                    lambda reader, writer, peer=peer: self.relay(peer, reader, writer), path=path
                )
                path.chmod(0o600)
                servers.append(server)
                bound.append(path)
            print("Agent routing ready", flush=True)
            await asyncio.gather(*(server.serve_forever() for server in servers))
        finally:
            for server in servers:
                server.close()
            for server in servers:
                await server.wait_closed()
            for path in bound:
                with contextlib.suppress(FileNotFoundError):
                    path.unlink()
            os.close(lock_fd)

    async def status(self):
        self.prepare()
        result = {}
        for peer in self.peers:
            try:
                _, writer, path = await self.connect(peer)
                writer.close()
                await writer.wait_closed()
                result[peer] = {"available": True, "forwarded_socket": path}
            except (OSError, ConnectionError):
                result[peer] = {"available": False}
        return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("register", "serve", "path", "status"))
    parser.add_argument("source", nargs="?")
    args = parser.parse_args()
    routing = Routing()
    if args.action == "register":
        routing.register(os.environ.get("SSH_CONNECTION", ""), os.environ.get("SSH_AUTH_SOCK", ""))
    elif args.action == "serve":
        asyncio.run(routing.serve())
    elif args.action == "status":
        print(json.dumps(asyncio.run(routing.status()), indent=2))
    else:
        if args.source not in ("local", *routing.peers):
            parser.error("path requires local, omarchy, or devtop")
        print(routing.local if args.source == "local" else routing.root / f"{args.source}.sock")


if __name__ == "__main__":
    os.umask(0o077)
    try:
        main()
    except (OSError, ValueError, ConnectionError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
