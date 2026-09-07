[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$tools = Join-Path $repoRoot '.tools'
$vcpkg = Join-Path $tools 'vcpkg'
$installed = Join-Path $tools 'vcpkg_installed'
$downloads = Join-Path $tools 'vcpkg_downloads'
$vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'

if (-not (Test-Path -LiteralPath $vswhere)) {
    throw 'Visual Studio Installer was not found. Install Visual Studio 2019 with Desktop development with C++ first.'
}

$vs2019 = & $vswhere -products * -version '[16.0,17.0)' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vs2019) {
    throw 'Visual Studio 2019 with the MSVC x64 toolchain is required.'
}

python -m pip install --user --upgrade cmake ninja
if ($LASTEXITCODE -ne 0) { throw 'CMake/Ninja installation failed.' }

$pythonUserSite = python -m site --user-site
$pythonScripts = Join-Path (Split-Path -Parent $pythonUserSite) 'Scripts'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathParts = @($userPath -split ';' | Where-Object { $_ })
if ($pathParts -notcontains $pythonScripts) {
    [Environment]::SetEnvironmentVariable('Path', (($pathParts + $pythonScripts) -join ';'), 'User')
}

if (-not (Test-Path -LiteralPath (Join-Path $vcpkg '.git'))) {
    New-Item -ItemType Directory -Force -Path $tools | Out-Null
    git clone https://github.com/microsoft/vcpkg.git $vcpkg
    if ($LASTEXITCODE -ne 0) { throw 'vcpkg clone failed.' }
}

& (Join-Path $vcpkg 'bootstrap-vcpkg.bat') -disableMetrics
if ($LASTEXITCODE -ne 0) { throw 'vcpkg bootstrap failed.' }

$env:VCPKG_VISUAL_STUDIO_PATH = $vs2019
$env:VCPKG_DOWNLOADS = $downloads
& (Join-Path $vcpkg 'vcpkg.exe') install `
    --triplet x64-windows `
    "--x-manifest-root=$repoRoot" `
    "--x-install-root=$installed" `
    "--downloads-root=$downloads"
if ($LASTEXITCODE -ne 0) { throw 'C++ dependency installation failed.' }

$code = Get-Command 'code' -ErrorAction SilentlyContinue
if ($code) {
    & $code.Source --install-extension ms-vscode.cpptools --force
    & $code.Source --install-extension ms-vscode.cmake-tools --force
}

Write-Host 'Setup complete. Open a new VS Code window, then run scripts\games101.ps1 verify.'
