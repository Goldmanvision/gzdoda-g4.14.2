[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$LaptopSource,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$DesktopSource,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$ProjectRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$FrameChars = @(
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','[','\\',']'
)

function Get-FrameNumber {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    if ($File.BaseName -match '(?:\s|_|-)(\d+)$') {
        return [int]$Matches[1]
    }

    if ($File.BaseName -match '^(?:DLAPBA|DDESA)(\d+)$') {
        return [int]$Matches[1]
    }

    throw "Cannot find a usable frame number in '$($File.Name)'. Expected individual frame PNGs like 'DLAPBA24.png' or 'DDESA38.png'. Sprite sheets such as 'DLAPA0_.png' are not valid input."
}

function Get-FrameName {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][int]$Ordinal
    )

    if ($Root.Length -ne 4) {
        throw "Sprite root '$Root' must be exactly four characters."
    }

    if ($Ordinal -lt 0 -or $Ordinal -ge $FrameChars.Count) {
        throw "Frame ordinal $Ordinal exceeds the 29-frame limit for one Doom sprite root. Split the animation into another root."
    }

    return "$Root$($FrameChars[$Ordinal])0.png"
}

function Get-TargetName {
    param(
        [Parameter(Mandatory = $true)][hashtable[]]$Rules,
        [Parameter(Mandatory = $true)][int]$SourceFrame
    )

    foreach ($rule in $Rules) {
        if ($SourceFrame -ge $rule.First -and $SourceFrame -le $rule.Last) {
            return Get-FrameName -Root $rule.Root -Ordinal ($SourceFrame - $rule.First)
        }
    }

    throw "No naming rule exists for source frame $SourceFrame."
}

function New-RenameJobs {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][hashtable[]]$Rules,
        [Parameter(Mandatory = $true)][string]$TargetDir
    )

    $files = @(Get-ChildItem -LiteralPath $Source -File -Filter '*.png' |
        Where-Object {
            $_.Name -notmatch '^[A-Z0-9\[\]\\]{6}\.png$' -and
            $_.BaseName -notmatch '(_$|sheet)'
        })

    if ($files.Count -eq 0) {
        throw "$Label source folder contains no usable unprocessed PNG files: $Source"
    }

    foreach ($file in $files) {
        $frame = Get-FrameNumber -File $file
        $newName = Get-TargetName -Rules $Rules -SourceFrame $frame

        [pscustomobject]@{
            Label  = $Label
            Source = $file.FullName
            Target = Join-Path $TargetDir $newName
        }
    }
}

$LaptopRules = @(
    @{ First = 0;  Last = 0;  Root = 'DLPO' },
    @{ First = 1;  Last = 1;  Root = 'DLPB' },
    @{ First = 2;  Last = 2;  Root = 'DLPN' },
    @{ First = 3;  Last = 21; Root = 'DLBF' },
    @{ First = 22; Last = 22; Root = 'DLPS' },
    @{ First = 23; Last = 23; Root = 'DLPR' },
    @{ First = 24; Last = 29; Root = 'DLMM' },
    @{ First = 30; Last = 34; Root = 'DLDC' },
    @{ First = 35; Last = 37; Root = 'DLOP' },
    @{ First = 38; Last = 49; Root = 'DLP1' },
    @{ First = 50; Last = 64; Root = 'DLP2' }
)

$DesktopRules = @(
    @{ First = 0;  Last = 25; Root = 'DCSV' },
    @{ First = 26; Last = 37; Root = 'DCSW' },
    @{ First = 38; Last = 38; Root = 'DCSR' }
)

$ProjectPath = [System.IO.Path]::GetFullPath($ProjectRoot)
$ComputersPath = Join-Path $ProjectPath 'doda-core\sprites\world\computers'

if ($PSCmdlet.ShouldProcess($ComputersPath, 'Create directory')) {
    New-Item -ItemType Directory -Path $ComputersPath -Force | Out-Null
}

$Jobs = @()
$Jobs += @(New-RenameJobs -Label 'Laptop'  -Source $LaptopSource  -Rules $LaptopRules  -TargetDir $ComputersPath)
$Jobs += @(New-RenameJobs -Label 'Desktop' -Source $DesktopSource -Rules $DesktopRules -TargetDir $ComputersPath)

$DuplicateTargets = @($Jobs | Group-Object Target | Where-Object Count -gt 1)
if ($DuplicateTargets.Count -gt 0) {
    $names = ($DuplicateTargets | ForEach-Object Name) -join ', '
    throw "Multiple source files map to the same target name: $names"
}

foreach ($job in $Jobs) {
    if (Test-Path -LiteralPath $job.Target) {
        throw "Refusing to overwrite existing sprite: $($job.Target)"
    }
}

foreach ($job in $Jobs | Sort-Object Target) {
    if ($PSCmdlet.ShouldProcess($job.Source, "Move and rename to '$($job.Target)'") ) {
        Move-Item -LiteralPath $job.Source -Destination $job.Target
    }
}

Write-Host "Renamed $($Jobs.Count) sprite PNGs." -ForegroundColor Green
Write-Host "Computers target: $ComputersPath"