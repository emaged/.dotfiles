import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[2]
SHARED_LINKS = {
    ".zshenv": "zsh/.zshenv",
    ".ssh/config.d/1password.conf": "ssh/.ssh/config.d/1password.conf",
    ".ssh/agent-routing.py": "ssh/.ssh/agent-routing.py",
    ".ssh/agent-peers.json": "ssh/.ssh/agent-peers.json",
    ".ssh/rc": "ssh/.ssh/rc",
    ".config/systemd/user/ssh-agent-routing.service": "ssh/.config/systemd/user/ssh-agent-routing.service",
    ".config/environment.d/ssh-agent.conf": "ssh/.config/environment.d/ssh-agent.conf",
}


class StowLayoutTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="ssh-stow-")
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name) / "home"
        self.packages = self.home / ".dotfiles"
        self.packages.mkdir(parents=True)
        for package in ("ssh", "zsh", "ssh-omarchy", "ssh-devtop"):
            shutil.copytree(REPO / package, self.packages / package,
                            ignore=shutil.ignore_patterns("__pycache__"))
        for directory in (".ssh/config.d", ".config/environment.d", ".config/systemd/user"):
            (self.home / directory).mkdir(parents=True)
        (self.home / ".ssh").chmod(0o700)
        self.keep = self.home / ".ssh/unrelated-file"
        self.keep.write_text("preserve this file\n")
        (self.home / ".config/environment.d/unrelated.conf").write_text("KEEP=yes\n")
        # A generated cache beside the helper must not become a deployed link.
        cache = self.packages / "ssh/.ssh/__pycache__"
        cache.mkdir(exist_ok=True)
        (cache / "agent-routing.cpython-test.pyc").write_bytes(b"test cache")

    def stow(self, *arguments, check=True):
        env = os.environ.copy()
        env["HOME"] = str(self.home)
        return subprocess.run(["stow", f"--dir={self.packages}", f"--target={self.home}",
                               *arguments], env=env, capture_output=True, text=True, check=check)

    def assert_links(self, computer):
        expected = {**SHARED_LINKS, ".ssh/config": f"ssh-{computer}/.ssh/config"}
        for name, target in expected.items():
            path = self.home / name
            self.assertTrue(path.is_symlink(), name)
            self.assertFalse(os.path.isabs(os.readlink(path)), name)
            self.assertEqual(path.resolve(), self.packages / target, name)
        for name in ("hosts", "tests", "README.md", ".stow-local-ignore", ".ssh/__pycache__"):
            self.assertFalse(os.path.lexists(self.home / name), name)
        self.assertEqual(self.keep.read_text(), "preserve this file\n")
        self.assertEqual((self.home / ".ssh").stat().st_mode & 0o777, 0o700)

    def test_stow_restow_and_unstow_both_host_packages(self):
        for computer in ("omarchy", "devtop"):
            with self.subTest(computer=computer):
                packages = ("ssh", "zsh", f"ssh-{computer}")
                self.stow(*packages)
                self.assert_links(computer)
                self.stow("--restow", *packages)
                self.assert_links(computer)
                self.stow("--delete", *packages)
                for name in (*SHARED_LINKS, ".ssh/config"):
                    self.assertFalse(os.path.lexists(self.home / name), name)
                self.assertEqual(self.keep.read_text(), "preserve this file\n")
                self.assertEqual((self.home / ".config/environment.d/unrelated.conf").read_text(), "KEEP=yes\n")

    def test_other_host_package_conflicts_without_changing_current_config(self):
        self.stow("ssh", "zsh", "ssh-omarchy")
        result = self.stow("--simulate", "ssh-devtop", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("conflict", result.stderr.lower())
        self.assert_links("omarchy")


if __name__ == "__main__":
    unittest.main()
