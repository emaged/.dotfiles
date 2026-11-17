import asyncio
import contextlib
import importlib.util
import json
import os
from pathlib import Path
import socket
import tempfile
import unittest


MODULE = Path(__file__).resolve().parents[1] / ".ssh/agent-routing.py"
spec = importlib.util.spec_from_file_location("agent_routing", MODULE)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
PEERS = {"omarchy": ["100.87.106.106"], "devtop": ["100.74.195.93"]}


class RoutingTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="agent-test-")
        self.base = Path(self.temp.name)
        self.routing = module.Routing(runtime=self.base, peers=PEERS, home=self.base / "home")
        self.routing.prepare()
        self.servers = []
        self.calls = []
        self.relay = asyncio.create_task(self.routing.serve())
        for _ in range(100):
            if (self.routing.root / "devtop.sock").exists():
                break
            await asyncio.sleep(0.01)
        else:
            await self.relay
            self.fail("Relay did not start")

    async def asyncTearDown(self):
        self.relay.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await self.relay
        for server in self.servers:
            server.close()
            await server.wait_closed()
        self.temp.cleanup()

    async def agent(self, name, response=None, delay=0):
        path = self.base / f"{name}.sock"

        async def respond(reader, writer):
            try:
                data = await reader.read(4096)
                if data:
                    self.calls.append(name)
                    await asyncio.sleep(delay)
                    writer.write(response if response is not None else name.encode() + b":" + data)
                    await writer.drain()
            finally:
                writer.close()
                await writer.wait_closed()

        server = await asyncio.start_unix_server(respond, path=path)
        path.chmod(0o600)
        self.servers.append(server)
        return path, server

    def register(self, path, peer="omarchy"):
        self.routing.register(f"{PEERS[peer][0]} 1234 100.64.0.1 22", str(path))

    async def request(self, peer="omarchy", half_close=False):
        reader, writer = await asyncio.open_unix_connection(self.routing.root / f"{peer}.sock")
        try:
            writer.write(b"request")
            await writer.drain()
            if half_close:
                writer.write_eof()
            return await asyncio.wait_for(reader.read(), 3)
        except ConnectionResetError:
            return b""
        finally:
            writer.close()
            with contextlib.suppress(ConnectionResetError):
                await writer.wait_closed()

    async def test_each_source_is_isolated(self):
        desktop, _ = await self.agent("desktop")
        laptop, _ = await self.agent("laptop")
        self.register(laptop)
        self.register(desktop, "devtop")
        self.assertEqual(await self.request(), b"laptop:request")
        self.assertEqual(await self.request("devtop"), b"desktop:request")

    async def test_short_connection_does_not_break_long_connection(self):
        long, _ = await self.agent("long")
        short, short_server = await self.agent("short")
        self.register(long)
        self.register(short)
        self.assertEqual(await self.request(), b"short:request")
        short_server.close()
        await short_server.wait_closed()
        self.assertEqual(await self.request(), b"long:request")

    async def test_reconnect_keeps_the_same_proxy_path(self):
        old, server = await self.agent("old")
        self.register(old)
        proxy_inode = (self.routing.root / "omarchy.sock").stat().st_ino
        self.assertEqual(await self.request(), b"old:request")
        server.close()
        await server.wait_closed()
        self.assertEqual(await self.request(), b"")
        new, _ = await self.agent("new")
        self.register(new)
        self.assertEqual(await self.request(), b"new:request")
        self.assertEqual((self.routing.root / "omarchy.sock").stat().st_ino, proxy_inode)

    async def test_missing_source_never_uses_other_source_or_local_agent(self):
        other, _ = await self.agent("other")
        self.register(other, "devtop")
        self.assertEqual(await self.request(), b"")
        self.assertEqual(self.calls, [])

    async def test_subshell_registration_does_not_reorder_connections(self):
        old, _ = await self.agent("old")
        new, _ = await self.agent("new")
        self.register(old)
        self.register(new)
        records = sorted((self.routing.root / "connections").glob("*.json"))
        before = {str(p): p.stat().st_mtime_ns for p in records}
        self.register(old)
        self.assertEqual(before, {str(p): p.stat().st_mtime_ns for p in records})
        self.assertEqual(await self.request(), b"new:request")

    async def test_empty_and_slow_agents_are_valid(self):
        # A valid SSH_AGENT_IDENTITIES_ANSWER with zero keys.
        empty_answer = b"\x00\x00\x00\x05\x0c\x00\x00\x00\x00"
        empty, _ = await self.agent("empty", response=empty_answer, delay=1.1)
        self.register(empty)
        self.assertEqual(await self.request(), empty_answer)

    async def test_half_closed_client_still_receives_response(self):
        path, _ = await self.agent("agent")
        self.register(path)
        self.assertEqual(await self.request(half_close=True), b"agent:request")

    async def test_unknown_source_symlink_and_exposed_socket_are_rejected(self):
        path, _ = await self.agent("agent")
        with self.assertRaises(ValueError):
            self.routing.register("100.64.0.2 1234 100.64.0.1 22", str(path))
        link = self.base / "link.sock"
        link.symlink_to(path)
        with self.assertRaises(ValueError):
            self.register(link)
        path.chmod(0o666)
        with self.assertRaises(ValueError):
            self.register(path)

    async def test_local_and_proxy_sockets_are_rejected(self):
        for path in (self.routing.local, self.routing.root / "omarchy.sock"):
            with self.assertRaises(ValueError):
                self.register(path)

    async def test_replaced_socket_requires_a_new_registration(self):
        path, server = await self.agent("reused")
        self.register(path)
        server.close()
        await server.wait_closed()
        # Keep an extra inode allocated so the filesystem cannot reuse the old one.
        spare = self.base / "spare"
        spare.write_text("spare")
        replacement, _ = await self.agent("reused")
        self.assertEqual(await self.request(), b"")
        self.register(replacement)
        self.assertEqual(await self.request(), b"reused:request")

    async def test_bad_record_does_not_mask_a_valid_connection(self):
        path, _ = await self.agent("good")
        self.register(path)
        bad = self.routing.root / "connections/omarchy-bad.json"
        bad.write_text('{"peer": "devtop"}')
        bad.chmod(0o600)
        self.assertEqual(await self.request(), b"good:request")

    async def test_permissions_are_private(self):
        path, _ = await self.agent("agent")
        self.register(path)
        for directory in (self.routing.root, self.routing.root / "connections"):
            self.assertEqual(directory.stat().st_mode & 0o777, 0o700)
        for entry in (self.routing.root / "connections").glob("*.json"):
            self.assertEqual(entry.stat().st_mode & 0o777, 0o600)
        self.assertEqual((self.routing.root / "omarchy.sock").stat().st_mode & 0o777, 0o600)


if __name__ == "__main__":
    unittest.main()
