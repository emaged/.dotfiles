#!/usr/bin/env python3
"""Offline regression checks. Never invokes a real installer or package manager."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
LINUX = ("omarchy", "ubuntu", "wsl")


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="bootstrap-test-")
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.home = self.directory / "home"
        self.bin = self.directory / "bin"
        self.scratch = self.directory / "scratch"
        self.log = self.directory / "commands"
        for path in (self.home, self.bin, self.scratch):
            path.mkdir()
        self.env = {
            "HOME": str(self.home), "USER": "bootstrap-test", "LANG": "C.UTF-8",
            "PATH": f"{self.bin}:/usr/bin:/bin", "TMPDIR": str(self.scratch),
            "XDG_RUNTIME_DIR": str(self.directory), "TEST_LOG": str(self.log),
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "XDG_DATA_HOME": str(self.home / ".local/share"),
        }
        # Fail closed if any test accidentally reaches an installer we didn't mock.
        for command in ("sudo", "pacman", "yay", "omarchy", "curl", "mise", "npm",
                        "cargo", "rustup", "pipx", "git", "systemctl", "chsh",
                        "gem", "snap", "apt-get", "apt-cache", "hyprpm"):
            self.stub(command, 'printf "UNEXPECTED %s\\n" "$0" >> "$TEST_LOG"\nexit 97\n')

    def stub(self, name, code):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\nset -eu\n" + code)
        path.chmod(0o755)

    def run_bash(self, *arguments):
        return subprocess.run(["/usr/bin/bash", *map(str, arguments)], cwd=self.directory,
                              env=self.env, text=True, capture_output=True, timeout=15)

    def helper(self, platform, code):
        return self.run_bash("-c", 'set -euo pipefail; source "$1"; ' + code,
                             "test", ROOT / platform / "lib/common.sh")

    def commands(self):
        return self.log.read_text() if self.log.exists() else ""

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_all_bash_syntax(self):
        files = list(ROOT.rglob("*.sh")) + [ROOT / "omarchy/files/omarchy-tmux-theme-set"]
        for path in files:
            with self.subTest(path=path.relative_to(ROOT)):
                self.assert_success(self.run_bash("-n", path))

    def test_previews_and_help_never_run_commands_or_write_home(self):
        for platform in LINUX:
            for arguments in (("--help",), ("--list",), ("--dry-run",),
                              ("--dry-run", "neovim", "pipx")):
                with self.subTest(platform=platform, arguments=arguments):
                    result = self.run_bash(ROOT / platform / "install.sh", *arguments)
                    self.assert_success(result)
        self.assertEqual(self.commands(), "")
        self.assertEqual(list(self.home.iterdir()), [])
        self.assertEqual(list(self.scratch.iterdir()), [])

    def test_selection_includes_prerequisites_once(self):
        for platform in LINUX:
            result = self.run_bash(ROOT / platform / "install.sh", "--dry-run", "neovim", "pipx")
            self.assert_success(result)
            modules = [line.strip() for line in result.stdout.splitlines() if line.startswith("  ")]
            node = "npm" if platform == "omarchy" else "node"
            self.assertLess(modules.index("prerequisites"), modules.index("mise"))
            self.assertLess(modules.index("mise"), modules.index(node))
            self.assertLess(modules.index(node), modules.index("neovim"))
            self.assertEqual(modules.count("pipx"), 1)

    def test_invalid_selection_fails_before_any_commands(self):
        for platform in LINUX:
            for name in ("missing", "../install", "", "--unknown"):
                result = self.run_bash(ROOT / platform / "install.sh", "pipx", name)
                self.assertEqual(result.returncode, 2, result.stderr)
        self.assertEqual(self.commands(), "")

    def test_wsl_has_no_gui_or_hardware_modules(self):
        result = self.run_bash(ROOT / "wsl/install.sh", "--list")
        self.assert_success(result)
        for name in ("firefox", "brave", "vlc", "postman", "brightness_setup", "hyprland", "omarchy-plugins"):
            self.assertNotIn(name, result.stdout)
            self.assertFalse((ROOT / "wsl/modules" / f"{name}.sh").exists())

    def test_platforms_have_independent_aligned_manifests(self):
        inventories = {}
        for platform in (*LINUX, "windows"):
            inventories[platform] = {}
            for category in ("npm", "pipx", "cargo"):
                path = ROOT / platform / "packages" / f"{category}.txt"
                self.assertFalse(path.is_symlink())
                names = [line for line in path.read_text().splitlines() if line and not line.startswith("#")]
                self.assertEqual(len(names), len(set(names)))
                inventories[platform][category] = set(names)
        for category in ("npm", "pipx"):
            for platform in inventories:
                self.assertEqual(inventories[platform][category], inventories["ubuntu"][category])
        baseline = inventories["ubuntu"]["cargo"]
        self.assertEqual(inventories["omarchy"]["cargo"], baseline)
        self.assertEqual(inventories["wsl"]["cargo"], baseline - {"neovide"})
        self.assertEqual(inventories["windows"]["cargo"], baseline - {"tree-sitter-cli"})

    def test_pipx_matches_exact_names_and_surfaces_upgrade_failures(self):
        self.stub("pipx", '''printf '%s\\n' "$*" >> "$TEST_LOG"
case "$*" in
  'list --json') echo '{"venvs":{"pytest-helper":{},"poetry":{}}}' ;;
  'upgrade poetry') exit 71 ;;
esac
''')
        for platform in LINUX:
            result = self.run_bash(ROOT / platform / "modules/pipx.sh")
            self.assertEqual(result.returncode, 71, result.stdout + result.stderr)
        self.assertIn("install black", self.commands())
        self.assertIn("upgrade poetry", self.commands())
        self.assertNotIn("install poetry", self.commands())

    def test_pipx_malformed_inventory_does_not_install(self):
        self.stub("pipx", '''printf '%s\\n' "$*" >> "$TEST_LOG"
if [[ $* == 'list --json' ]]; then echo 'invalid json'; fi
''')
        result = self.run_bash(ROOT / "ubuntu/modules/pipx.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("install ", self.commands())

    def test_pipx_similar_name_is_not_treated_as_installed(self):
        self.stub("pipx", '''printf '%s\\n' "$*" >> "$TEST_LOG"
if [[ $* == 'list --json' ]]; then echo '{"venvs":{"pytest-helper":{}}}'; fi
''')
        self.assert_success(self.run_bash(ROOT / "ubuntu/modules/pipx.sh"))
        self.assertIn("install pytest\n", self.commands())
        self.assertNotIn("upgrade pytest", self.commands())

    def test_existing_mise_selection_is_not_replaced_or_upgraded(self):
        self.stub("mise", '''printf '%s\\n' "$*" >> "$TEST_LOG"
case "$3" in
  ls) echo '[{"version":"24.0.0","requested_version":"24"}]' ;;
  where) printf '%s\\n' "$HOME/node" ;;
  *) exit 89 ;;
esac
''')
        for platform in LINUX:
            self.assert_success(self.helper(platform, "ensure_mise_tool node"))
        self.assertNotIn(" use ", self.commands())
        self.assertNotIn(" install ", self.commands())
        self.assertIn(f"-C {self.home} ls", self.commands())

    def test_mise_inventory_failure_is_not_treated_as_missing(self):
        self.stub("mise", 'printf "%s\\n" "$*" >> "$TEST_LOG"\nexit 72\n')
        result = self.helper("ubuntu", "ensure_mise_tool node")
        self.assertEqual(result.returncode, 72, result.stderr)
        self.assertNotIn(" use ", self.commands())

    def test_failed_download_is_not_executed_and_is_cleaned_up(self):
        self.stub("curl", '''printf 'download\\n' >> "$TEST_LOG"
exit 22
''')
        self.stub("test-installer", 'printf "EXECUTED\\n" >> "$TEST_LOG"\n')
        result = self.helper("ubuntu", "run_installer https://example.invalid test-installer")
        self.assertEqual(result.returncode, 22, result.stderr)
        self.assertNotIn("EXECUTED", self.commands())
        self.assertEqual(list(self.scratch.iterdir()), [])

    def test_failed_installer_is_reported_and_cleaned_up(self):
        self.stub("curl", "exit 0\n")
        self.stub("test-installer", "exit 41\n")
        result = self.helper("ubuntu", "run_installer https://example.invalid test-installer")
        self.assertEqual(result.returncode, 41, result.stderr)
        self.assertEqual(list(self.scratch.iterdir()), [])

    def test_apt_without_candidate_is_unavailable(self):
        self.stub("apt-cache", "printf '  Candidate: (none)\\n'\n")
        self.assertEqual(self.helper("ubuntu", "apt_has_package lazygit").returncode, 1)
        self.stub("apt-cache", "printf '  Candidate: 1.2.3\\n'\n")
        self.assert_success(self.helper("ubuntu", "apt_has_package lazygit"))

    def test_development_tools_install_required_java_runtime(self):
        self.stub("sudo", 'printf "%s\\n" "$*" >> "$TEST_LOG"\n')
        self.stub("apt-cache", "printf '  Candidate: 1.0\\n'\n")
        self.stub("bat", "exit 0\n")
        self.stub("fd", "exit 0\n")
        for platform in ("ubuntu", "wsl"):
            with self.subTest(platform=platform):
                self.log.write_text("")
                self.assert_success(self.run_bash(ROOT / platform / "modules/dev-tools.sh"))
                installs = [line.split() for line in self.commands().splitlines()
                            if line.startswith("apt-get install ")]
                self.assertTrue(any("openjdk-25-jdk" in args for args in installs))

    def test_missing_required_java_stops_development_tools(self):
        self.stub("sudo", '''printf '%s\\n' "$*" >> "$TEST_LOG"
for argument in "$@"; do
  if [[ $argument == openjdk-25-jdk ]]; then exit 100; fi
done
''')
        for platform in ("ubuntu", "wsl"):
            with self.subTest(platform=platform):
                result = self.run_bash(ROOT / platform / "modules/dev-tools.sh")
                self.assertEqual(result.returncode, 100, result.stdout + result.stderr)
                self.assertNotIn("Development tools installed.", result.stdout)

    def test_system_npm_prefix_is_rejected(self):
        self.stub("npm", "echo /usr/local\n")
        result = self.helper("omarchy", "ensure_user_npm_prefix")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("system-managed", result.stderr)

    def test_failed_completion_preserves_existing_file(self):
        completion = self.home / ".zfunc/_codex"
        completion.parent.mkdir()
        completion.write_text("existing completion\n")
        self.stub("codex", "echo incomplete; exit 7\n")
        result = self.helper("ubuntu", "generate_completion codex codex completion zsh")
        self.assertEqual(result.returncode, 7)
        self.assertEqual(completion.read_text(), "existing completion\n")
        self.assertEqual(list(self.scratch.iterdir()), [])

    def test_omarchy_does_not_duplicate_mise_managed_npm_tools(self):
        (self.home / "npm").mkdir()
        self.stub("mise", '''printf 'mise %s\\n' "$*" >> "$TEST_LOG"
case "$3" in
  ls) echo '[{"version":"1"}]' ;;
  where) printf '%s\\n' "$HOME/mise-tool" ;;
  *) exit 89 ;;
esac
''')
        self.stub("npm", '''printf 'npm %s\\n' "$*" >> "$TEST_LOG"
case "$1" in
  prefix) printf '%s\\n' "$HOME/npm" ;;
  list) exit 1 ;;
  install) exit 0 ;;
  *) exit 89 ;;
esac
''')
        self.stub("codex", "echo 'generated completion'\n")
        self.assert_success(self.run_bash(ROOT / "omarchy/modules/npm.sh"))
        self.assertIn("npm install -g -- prettier", self.commands())
        for package in ("@openai/codex", "@github/copilot", "@mermaid-js/mermaid-cli"):
            self.assertNotIn("npm install -g -- " + package, self.commands())

    @unittest.skipIf(os.geteuid() == 0, "Runner deliberately refuses root")
    def test_ubuntu_refuses_wsl_before_installing(self):
        self.env["WSL_DISTRO_NAME"] = "Ubuntu"
        driver = '''source() {
  if [[ $1 == /etc/os-release ]]; then ID=ubuntu; VERSION_CODENAME=noble;
  else builtin source "$@"; fi
}
entry=$1
shift
source "$entry" "$@"
'''
        result = self.run_bash("-c", driver, "test", ROOT / "ubuntu/install.sh", "pipx")
        self.assertEqual(result.returncode, 2)
        self.assertIn("Use wsl/install.sh", result.stderr)
        self.assertEqual(self.commands(), "")

    def test_mongodb_does_not_add_a_different_ubuntu_suite(self):
        driver = '''source() {
  if [[ $1 == /etc/os-release ]]; then ID=ubuntu; VERSION_CODENAME=resolute;
  else builtin source "$@"; fi
}
entry=$1
shift
source "$entry" "$@"
'''
        for platform in ("ubuntu", "wsl"):
            result = self.run_bash("-c", driver, "test", ROOT / platform / "modules/mongodb.sh")
            self.assertEqual(result.returncode, 3, result.stderr)
            self.assertIn("SKIP", result.stderr)
        self.assertEqual(self.commands(), "")
        self.assertEqual(list(self.scratch.iterdir()), [])

    def run_fake_modules(self, platform, first_script):
        modules = self.directory / "modules"
        modules.mkdir(exist_ok=True)
        (modules / "first.sh").write_text("set -euo pipefail\n" + first_script)
        (modules / "last.sh").write_text('printf "last\\n" >> "$TEST_LOG"\n')
        driver = '''set -euo pipefail
ROOT_DIR=$PWD
PLATFORM=test
DEFAULT_MODULES=(first last)
OPTIONAL_MODULES=()
SKIPPABLE_MODULES=(first)
declare -A MODULE_DEPS=()
check_platform() { return 0; }
source "$1"
bootstrap_main
'''
        return self.run_bash("-c", driver, "test", ROOT / platform / "lib/runner.sh")

    @unittest.skipIf(os.geteuid() == 0, "Runner deliberately refuses root")
    def test_runner_stops_on_first_failure_without_disabling_errexit(self):
        for platform in LINUX:
            result = self.run_fake_modules(platform, 'false\nprintf "unexpected success\\n"\n')
            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertIn("FAILED: first", result.stderr)
            self.assertNotIn("unexpected success", result.stdout)
        self.assertEqual(self.commands(), "")

    @unittest.skipIf(os.geteuid() == 0, "Runner deliberately refuses root")
    def test_runner_reports_optional_skip_and_continues(self):
        result = self.run_fake_modules("ubuntu", "exit 3\n")
        self.assert_success(result)
        self.assertIn("optional modules skipped: first", result.stdout)
        self.assertEqual(self.commands(), "last\n")

    def test_existing_command_symlink_is_preserved(self):
        destination = self.home / ".local/bin/bootstrap-test-command"
        destination.parent.mkdir(parents=True)
        destination.symlink_to(self.home / "missing-target")
        result = self.helper("ubuntu", "link_command bootstrap-test-command /usr/bin/true")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(os.readlink(destination), str(self.home / "missing-target"))

    @unittest.skipIf(os.geteuid() == 0, "SSH helper deliberately refuses root")
    def test_ssh_conflicting_agent_is_not_changed(self):
        self.env["SSH_AUTH_SOCK"] = "/existing/agent.sock"
        self.stub("systemctl", 'printf "%s\\n" "$*" >> "$TEST_LOG"\n')
        result = self.run_bash(ROOT / "wsl/ssh-setup.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("enable", self.commands())
        self.assertEqual(list(self.home.iterdir()), [])

    @unittest.skipIf(os.geteuid() == 0, "SSH helper deliberately refuses root")
    def test_ssh_fallback_is_repeatable_without_native_socket(self):
        self.stub("systemctl", '''printf '%s\\n' "$*" >> "$TEST_LOG"
case "$2" in cat|is-active|is-enabled) exit 1 ;; esac
''')
        for _ in range(2):
            self.assert_success(self.run_bash(ROOT / "wsl/ssh-setup.sh"))
        config = (self.home / ".ssh/config").read_text()
        self.assertEqual(config.count("# dotfiles bootstrap: SSH agent"), 1)
        self.assertNotIn("IdentityFile", config)
        self.assertTrue((self.home / ".config/systemd/user/dotfiles-ssh-agent.service").is_file())
        self.assertIn("enable --now dotfiles-ssh-agent.service", self.commands())


if __name__ == "__main__":
    unittest.main(verbosity=2)
