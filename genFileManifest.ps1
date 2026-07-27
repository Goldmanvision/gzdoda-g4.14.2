[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TargetPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ResolvedTarget = [System.IO.Path]::GetFullPath($TargetPath)
if (-not (Test-Path -LiteralPath $ResolvedTarget -PathType Container)) {
    throw "Target directory does not exist: $ResolvedTarget"
}

$DirectoryInfo = Get-Item -LiteralPath $ResolvedTarget
$ManifestName = '{0}.manifest.txt' -f $DirectoryInfo.Name
$ManifestPath = Join-Path $ResolvedTarget $ManifestName

$Lines = dir -LiteralPath $ResolvedTarget -Recurse | ForEach-Object {
    if ($_.PSIsContainer) {
        $_.FullName + '\'
    }
    else {
        $_.FullName
    }
}

Set-Content -LiteralPath $ManifestPath -Value $Lines -Encoding UTF8
Write-Host "Manifest written: $ManifestPath" -ForegroundColor Green