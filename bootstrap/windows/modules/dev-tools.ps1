Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir 'common.ps1')

Write-Step 'Installing development tools...'

$wingetPackages = @(
    @{ Id = 'Git.Git'; Name = 'Git' },
    @{ Id = 'Rustlang.Rustup'; Name = 'Rustup' },
    @{ Id = 'Apache.Maven'; Name = 'Maven' },
    @{ Id = 'ImageMagick.ImageMagick'; Name = 'ImageMagick' },
    @{ Id = 'GitLab.GLab'; Name = 'GitLab CLI' },
    @{ Id = 'LLVM.LLVM'; Name = 'LLVM' },
    @{ Id = 'Microsoft.OpenJDK.21'; Name = 'Microsoft OpenJDK 21' },
    @{ Id = 'Microsoft.OpenJDK.17'; Name = 'Microsoft OpenJDK 17' },
    @{ Id = 'Microsoft.OpenJDK.11'; Name = 'Microsoft OpenJDK 11' },
    @{ Id = 'EclipseAdoptium.Temurin.8.JDK'; Name = 'Temurin JDK 8' },
    @{ Id = 'RubyInstallerTeam.RubyWithDevKit.3.4'; Name = 'Ruby 3.4 with DevKit' },
    @{ Id = 'Kitware.CMake'; Name = 'CMake' },
    @{ Id = 'Ninja-build.Ninja'; Name = 'Ninja' },
    @{ Id = 'Clement.bottom'; Name = 'bottom' },
    @{ Id = 'sharkdp.bat'; Name = 'bat' },
    @{ Id = 'dandavison.delta'; Name = 'delta' },
    @{ Id = 'eza-community.eza'; Name = 'eza' },
    @{ Id = 'sharkdp.fd'; Name = 'fd' },
    @{ Id = 'dundee.gdu'; Name = 'gdu' },
    @{ Id = 'jqlang.jq'; Name = 'jq' },
    @{ Id = 'JesseDuffield.lazygit'; Name = 'lazygit' },
    @{ Id = 'FiloSottile.mkcert'; Name = 'mkcert' },
    @{ Id = 'BurntSushi.ripgrep.MSVC'; Name = 'ripgrep' },
    @{ Id = 'ajeetdsouza.zoxide'; Name = 'zoxide' }
)

foreach ($package in $wingetPackages) {
    Install-WingetPackage -Id $package.Id -Name $package.Name
}

Ensure-Scoop
Ensure-ScoopBucket -Name 'main'

$scoopPackages = @(
    'ghostscript',
    'luarocks',
    'meson',
    'tectonic',
    'wget',
    'tree-sitter'
)

foreach ($package in $scoopPackages) {
    Install-ScoopPackage -Package $package
}

Write-Info 'Development tools installed.'
