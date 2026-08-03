param(
    [string]$GZDoomPath = $env:DODA_GZDOOM_PATH,
    [string]$IwadPath = $env:DODA_IWAD_PATH,
    [string]$SourceDir = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
$root = $SourceDir
$outDir = Join-Path $root 'output'
$stage = Join-Path $outDir 'stage'
$pk3 = Join-Path $outDir 'DoDA_Test.pk3'

New-Item -ItemType Directory -Force -Path $outDir, $stage | Out-Null
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $stage | Out-Null

$src = Join-Path $root 'doda-core'
if (-not (Test-Path $src)) { throw "Missing source folder: $src" }

Copy-Item -Path (Join-Path $src '*') -Destination $stage -Recurse -Force
if (Test-Path $pk3) { Remove-Item $pk3 -Force }
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $pk3 -Force

if (-not $GZDoomPath) {
    $cmd = Get-Command GZDOOM.exe -ErrorAction SilentlyContinue
    if ($cmd) { $GZDoomPath = $cmd.Source }
}
if (-not $GZDoomPath -or -not (Test-Path $GZDoomPath)) {
    throw "GZDOOM.exe not found. Set PATH or DODA_GZDOOM_PATH."
}

$args = @('-file', $pk3)
if ($IwadPath) {
    if (-not (Test-Path $IwadPath)) { throw "IWAD not found: $IwadPath" }
    $args = @('-iwad', $IwadPath) + $args
}

Start-Process -FilePath $GZDoomPath -ArgumentList $args -WorkingDirectory $root