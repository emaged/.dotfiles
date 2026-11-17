import os
from pathlib import Path
import socket
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ALIASES = (
    "omarchy", "devtop", "omarchy.tail2cf8dd.ts.net", "devtop.tail2cf8dd.ts.net",
    "omarchy.tail2cf8dd.ts.net.", "devtop.tail2cf8dd.ts.net.",
    "100.87.106.106", "100.74.195.93", "fd7a:115c:a1e0::112f:6a6c", "fd7a:115c:a1e0::8b2f:c35e",
)


class ConfigTests(unittest.TestCase):
    def config(self, computer, destination="github.com", choice=None, incoming=False):
        text = (ROOT.parent / f"ssh-{computer}/.ssh/config").read_text().replace(
            "~/.ssh/config.d/1password.conf", str(ROOT / ".ssh/config.d/1password.conf")
        )
        env = os.environ.copy()
        for key in ("DOTFILES_AGENT_CHOICE", "SSH_CONNECTION", "SSH_TTY"):
            env.pop(key, None)
        env["SSH_AUTH_SOCK"] = "/tmp/selected-test-agent.sock"
        if choice is not None:
            env["DOTFILES_AGENT_CHOICE"] = choice
        if incoming:
            env["SSH_CONNECTION"] = "100.87.106.106 1234 100.74.195.93 22"
        with tempfile.NamedTemporaryFile(mode="w") as config:
            config.write(text)
            config.flush()
            result = subprocess.run(["ssh", "-G", "-F", config.name, destination],
                                    env=env, capture_output=True, text=True, check=True)
        data = {}
        for line in result.stdout.splitlines():
            key, _, value = line.partition(" ")
            data.setdefault(key, []).append(value)
        return data

    def assert_local(self, data):
        self.assertEqual(Path(data["identityagent"][0]).expanduser(), Path.home() / ".1password/agent.sock")

    def test_local_sessions_ignore_a_stale_system_agent_environment(self):
        for computer in ("omarchy", "devtop"):
            with self.subTest(computer=computer):
                data = self.config(computer)
                self.assert_local(data)
                self.assertNotIn("none", data["identityfile"])
                self.assertEqual(data["forwardagent"], ["no"])

    def test_selected_and_incoming_sessions_use_only_the_forwarded_agent(self):
        for computer in ("omarchy", "devtop"):
            for choice, incoming in (("devtop", False), ("omarchy", False), (None, True)):
                with self.subTest(computer=computer, choice=choice, incoming=incoming):
                    data = self.config(computer, choice=choice, incoming=incoming)
                    self.assertIn(data["identityagent"][0], ("SSH_AUTH_SOCK", "/tmp/selected-test-agent.sock"))
                    self.assertEqual(data["identityfile"], ["none"])
                    self.assertEqual(data["addkeystoagent"], ["false"])

    def test_explicit_local_selection_overrides_incoming_session(self):
        for computer in ("omarchy", "devtop"):
            data = self.config(computer, choice="local", incoming=True)
            self.assert_local(data)
            self.assertNotIn("none", data["identityfile"])

    def test_every_peer_alias_forwards_local_1password_even_when_remote_is_selected(self):
        for alias in ALIASES:
            with self.subTest(alias=alias):
                data = self.config("devtop", destination=alias, choice="omarchy")
                self.assert_local(data)
                self.assertEqual(Path(data["forwardagent"][0]).expanduser(), Path.home() / ".1password/agent.sock")

    def test_friendly_names_match_the_confirmed_physical_computers(self):
        with tempfile.TemporaryDirectory(prefix="agent-alias-") as temporary:
            home = Path(temporary)
            (home / ".ssh").mkdir()
            (home / ".ssh/agent-routing.py").symlink_to(ROOT / ".ssh/agent-routing.py")
            runtime = home / "ssh-agent-routing"
            runtime.mkdir()
            sockets = []
            try:
                for host in ("omarchy", "devtop"):
                    endpoint = socket.socket(socket.AF_UNIX)
                    endpoint.bind(str(runtime / f"{host}.sock"))
                    sockets.append(endpoint)
                env = os.environ.copy()
                for key in ("DOTFILES_AGENT_CHOICE", "SSH_CONNECTION", "SSH_AUTH_SOCK"):
                    env.pop(key, None)
                env.update(HOME=str(home), XDG_RUNTIME_DIR=str(home))
                shell = ROOT.parent / "zsh/.zshenv"
                for computer in ("omarchy", "devtop"):
                    for alias, target in (("laptop", "omarchy"), ("desktop", "devtop")):
                        with self.subTest(computer=computer, alias=alias):
                            script = f'HOST={computer}; source "{shell}"; agent-use {alias} >/dev/null; print -r -- "$DOTFILES_AGENT_CHOICE|$SSH_AUTH_SOCK"'
                            result = subprocess.run(["zsh", "-fc", script], env=env, capture_output=True, text=True, check=True)
                            expected = "local" if computer == target else target
                            path = home / ".1password/agent.sock" if expected == "local" else runtime / f"{target}.sock"
                            self.assertEqual(result.stdout.strip(), f"{expected}|{path}")
            finally:
                for endpoint in sockets:
                    endpoint.close()

    def test_other_dotfiles_installations_keep_their_existing_agent(self):
        with tempfile.TemporaryDirectory(prefix="agent-uninstalled-") as temporary:
            env = os.environ.copy()
            env.update(HOME=temporary, SSH_AUTH_SOCK="/tmp/existing-agent.sock")
            env.pop("SSH_CONNECTION", None)
            env.pop("DOTFILES_AGENT_CHOICE", None)
            shell = ROOT.parent / "zsh/.zshenv"
            result = subprocess.run(["zsh", "-fc", f'source "{shell}"; print -r -- "$SSH_AUTH_SOCK"'],
                                    env=env, capture_output=True, text=True, check=True)
            self.assertEqual(result.stdout.strip(), "/tmp/existing-agent.sock")


if __name__ == "__main__":
    unittest.main()
