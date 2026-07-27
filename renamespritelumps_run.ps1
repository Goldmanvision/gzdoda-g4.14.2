Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptPath = 'C:\dev\gzdoda-g4.14.2\renameSpriteLumps_src.ps1'
$LaptopSource = 'C:\dev\gzdoda-g4.14.2\aseprite\FBI_laptop_a'
$DesktopSource = 'C:\dev\gzdoda-g4.14.2\aseprite\FBI_desktop_a'
$ProjectRoot = 'C:\dev\gzdoda-g4.14.2\gzdoda'

if ($MyInvocation.MyCommand.Path -eq $ScriptPath) {
    throw 'renameSpriteLumps_run.ps1 is pointing at itself. Set $ScriptPath to renameSpriteLumps_src.ps1.'
}

Write-Host '--- DRY RUN ---' -ForegroundColor Cyan
& $ScriptPath `
    -LaptopSource $LaptopSource `
    -DesktopSource $DesktopSource `
    -ProjectRoot $ProjectRoot `
    -WhatIf

Write-Host ''
$answer = Read-Host 'Proceed with actual rename? Type Y to continue'
if ($answer -notin @('Y','y')) {
    Write-Host 'Aborted. No files were moved.' -ForegroundColor Yellow
    exit 0
}

Write-Host ''
Write-Host '--- REAL RUN ---' -ForegroundColor Cyan
Write-Host 'Showing per-file progress...' -ForegroundColor DarkYellow
& $ScriptPath `
    -LaptopSource $LaptopSource `
    -DesktopSource $DesktopSource `
    -ProjectRoot $ProjectRoot `
    -Verbose

Write-Host ''
Write-Host 'Rename operation finished.' -ForegroundColor Green