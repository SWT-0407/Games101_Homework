[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('configure', 'build', 'run', 'clean', 'verify')]
    [string]$Action = 'verify',

    [Parameter(Position = 1)]
    [ValidateSet('pa0', 'pa1', 'pa2', 'pa3', 'pa4', 'pa5', 'pa6', 'pa7', 'pa8')]
    [string]$Assignment = 'pa0',

    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$vcpkgRoot = Join-Path $repoRoot '.tools\vcpkg'
$toolchain = Join-Path $vcpkgRoot 'scripts\buildsystems\vcpkg.cmake'
$installed = Join-Path $repoRoot '.tools\vcpkg_installed'
$env:VCPKG_DOWNLOADS = Join-Path $repoRoot '.tools\vcpkg_downloads'
$env:VCPKG_DEFAULT_TRIPLET = 'x64-windows'

$cmakeCommand = Get-Command 'cmake.exe' -ErrorAction SilentlyContinue
if ($cmakeCommand) {
    $cmake = $cmakeCommand.Source
} else {
    $cmake = Get-ChildItem (Join-Path $env:APPDATA 'Python') -Recurse -Filter 'cmake.exe' -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}

$vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
$vs2019 = if (Test-Path -LiteralPath $vswhere) {
    & $vswhere -products * -version '[16.0,17.0)' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
}
if ($vs2019) {
    $env:VCPKG_VISUAL_STUDIO_PATH = $vs2019
}

$projects = @{
    pa0 = 'assignments\pa0\pa0'
    pa1 = 'assignments\Assignment1'
    pa2 = 'assignments\Assignment2'
    pa3 = 'assignments\Assignment3\Assignment3\Code'
    pa4 = 'assignments\Assignment4\code'
    pa5 = 'assignments\Assignment5\Code'
    pa6 = 'assignments\PA6\PA6\Assignment6'
    pa7 = 'assignments\PA7-1\PA7\Assignment7'
    pa8 = 'assignments\assignment8\assignment8'
}

function Get-ProjectSource {
    $base = Join-Path $repoRoot $projects[$Assignment]
    if ($Assignment -in @('pa1', 'pa2')) {
        $cmakeFile = Get-ChildItem -LiteralPath $base -Recurse -Filter 'CMakeLists.txt' |
            Sort-Object { $_.FullName.Length } |
            Select-Object -First 1
        if (-not $cmakeFile) { throw "CMakeLists.txt not found below $base" }
        return $cmakeFile.DirectoryName
    }
    return $base
}

$executables = @{
    pa0 = 'Transformation.exe'
    pa1 = 'Rasterizer.exe'
    pa2 = 'Rasterizer.exe'
    pa3 = 'Rasterizer.exe'
    pa4 = 'BezierCurve.exe'
    pa5 = 'RayTracing.exe'
    pa6 = 'RayTracing.exe'
    pa7 = 'RayTracing.exe'
    pa8 = 'ropesim.exe'
}

function Assert-Environment {
    $missing = @()
    if (-not $cmake -or -not (Test-Path -LiteralPath $cmake)) {
        $missing += 'CMake'
    }
    if (-not (Test-Path -LiteralPath $toolchain)) {
        $missing += $toolchain
    }

    if (-not (Test-Path -LiteralPath $vswhere)) {
        $missing += $vswhere
    } elseif (-not $vs2019) {
        $missing += 'Visual Studio 2019 C++ x64 toolchain'
    }

    if ($missing.Count -gt 0) {
        throw "Missing environment components:`n - $($missing -join "`n - ")"
    }
}

function Configure-Project {
    Assert-Environment
    $source = Get-ProjectSource
    $build = Join-Path $source 'build'
    & $cmake -S $source -B $build -G 'Visual Studio 16 2019' -A x64 `
        "-DCMAKE_TOOLCHAIN_FILE=$toolchain" `
        "-DVCPKG_MANIFEST_DIR=$repoRoot" `
        "-DVCPKG_INSTALLED_DIR=$installed" `
        '-DVCPKG_TARGET_TRIPLET=x64-windows' `
        '-DCMAKE_POLICY_VERSION_MINIMUM=3.5'
    if ($LASTEXITCODE -ne 0) { throw "CMake configure failed for $Assignment" }
}

function Build-Project {
    $source = Get-ProjectSource
    $build = Join-Path $source 'build'
    if (-not (Test-Path -LiteralPath (Join-Path $build 'CMakeCache.txt'))) {
        Configure-Project
    }
    if ($Assignment -eq 'pa8') {
        # The generated osdfont.c can exhaust MSVC heap when compiled beside all CGL sources.
        & $cmake --build $build --config $Configuration --parallel 1
    } else {
        & $cmake --build $build --config $Configuration --parallel
    }
    if ($LASTEXITCODE -ne 0) { throw "Build failed for $Assignment" }
}

switch ($Action) {
    'verify' {
        Assert-Environment
        & $cmake --version
        & (Join-Path $vcpkgRoot 'vcpkg.exe') version
        Write-Host 'Visual Studio 2019 C++, CMake, and vcpkg are available.'
    }
    'configure' { Configure-Project }
    'build' { Build-Project }
    'run' {
        Build-Project
        $source = Get-ProjectSource
        $candidates = @(
            (Join-Path $source "build\$Configuration\$($executables[$Assignment])"),
            (Join-Path $source "build\$($executables[$Assignment])"),
            (Join-Path $source "build\src\$Configuration\$($executables[$Assignment])")
        )
        $program = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        if (-not $program) { throw "Executable not found for $Assignment" }
        Push-Location $source
        try { & $program } finally { Pop-Location }
    }
    'clean' {
        $source = Get-ProjectSource
        $build = Join-Path $source 'build'
        if (Test-Path -LiteralPath $build) {
            Remove-Item -LiteralPath $build -Recurse -Force
        }
    }
}
