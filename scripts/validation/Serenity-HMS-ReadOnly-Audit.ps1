[CmdletBinding()]
param(
    [string]$RootPath = 'D:\SERENITY-HMS',
    [string]$ReportPath = "$env:TEMP\serenity-hms-audit-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
)

$ErrorActionPreference = 'Continue'
$RootPath = [IO.Path]::GetFullPath($RootPath)

if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
    throw "Project root not found: $RootPath"
}

$lines = [System.Collections.Generic.List[string]]::new()
function Add-Section([string]$Title) {
    $lines.Add('')
    $lines.Add(('=' * 78))
    $lines.Add($Title)
    $lines.Add(('=' * 78))
}
function Add-Output($Value) {
    foreach ($line in @($Value)) {
        if ($null -ne $line) { $lines.Add([string]$line) }
    }
}

Add-Section 'SERENITY HMS ENTERPRISE - READ-ONLY AUDIT'
Add-Output "Timestamp: $(Get-Date -Format o)"
Add-Output "Root: $RootPath"
Add-Output "This script does not create, edit, delete, or move project files."

Push-Location $RootPath
try {
    Add-Section 'GIT STATUS'
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Add-Output (git status --short --branch 2>&1)
    } else { Add-Output 'git: NOT INSTALLED' }

    Add-Section 'ROOT STRUCTURE'
    Add-Output (Get-ChildItem -Force | Select-Object Mode, Name, Length, LastWriteTime | Format-Table -AutoSize | Out-String -Width 220)

    Add-Section 'IMPORTANT FILES'
    $paths = @(
        'README.md','.env.example','go.mod','go.sum',
        'backend\cmd\api\main.go','backend\api\cmd\server\main.go',
        'backend\api\go.mod','backend\config\config.go',
        'backend\database\postgres.go','backend\database\database.go',
        'apps\customer-mobile\pubspec.yaml','apps\customer-mobile\lib\main.dart',
        'apps\landing-page\package.json','apps\landing-page\src\app\page.tsx',
        'apps\commander-web\package.json','apps\commander-web\src\app\page.tsx',
        'apps\staff-portal\package.json','database\migrations',
        'docker-compose.yml','compose.yaml'
    )
    foreach ($relative in $paths) {
        $item = Join-Path $RootPath $relative
        if (Test-Path -LiteralPath $item) {
            $obj = Get-Item -LiteralPath $item
            Add-Output ("FOUND   {0}{1}" -f $relative, $(if ($obj.PSIsContainer) {' [directory]'} else {" [file, $($obj.Length) bytes]"}))
        } else {
            Add-Output "MISSING $relative"
        }
    }

    Add-Section 'TOOLCHAIN'
    foreach ($name in @('git','go','flutter','dart','npm','node','python','docker','psql')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) {
            $version = (& $name --version 2>&1 | Select-Object -First 1)
            Add-Output ("{0}: {1} | {2}" -f $name, $cmd.Source, $version)
        } else { Add-Output "${name}: NOT FOUND" }
    }

    Add-Section 'GO MODULE AND SOURCE INVENTORY'
    if (Test-Path -LiteralPath (Join-Path $RootPath 'go.mod')) {
        Add-Output (Get-Content -LiteralPath (Join-Path $RootPath 'go.mod') -TotalCount 80)
    }
    $goFiles = Get-ChildItem -LiteralPath $RootPath -Recurse -File -Filter '*.go' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(vendor|node_modules|\.git)\\' } |
        Select-Object -First 100 FullName, Length
    if ($goFiles) { Add-Output ($goFiles | Format-Table -AutoSize | Out-String -Width 220) }
    else { Add-Output 'No Go source files found.' }

    Add-Section 'WEB APP MANIFESTS'
    foreach ($relative in @('apps\landing-page\package.json','apps\commander-web\package.json','apps\staff-portal\package.json')) {
        $file = Join-Path $RootPath $relative
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            Add-Output "--- $relative ---"
            Add-Output (Get-Content -LiteralPath $file -Raw)
        }
    }

    Add-Section 'LATEST PROJECT FILES'
    Add-Output (Get-ChildItem -LiteralPath $RootPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|build|dist|\.dart_tool)\\' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 30 @{n='Modified';e={$_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')}}, @{n='Bytes';e={$_.Length}}, @{n='Path';e={$_.FullName.Substring($RootPath.Length + 1)} } |
        Format-Table -AutoSize | Out-String -Width 240)
}
finally {
    Pop-Location
}

$lines | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Host "`nAudit complete. No project files were changed." -ForegroundColor Green
Write-Host "Report: $ReportPath" -ForegroundColor Cyan
Write-Host "`n===== AUDIT SUMMARY =====" -ForegroundColor Cyan
$lines | Select-Object -First 150
Write-Host "`nIf the report is longer, open it with: notepad `"$ReportPath`"" -ForegroundColor Yellow
