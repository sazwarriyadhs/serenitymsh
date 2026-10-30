[CmdletBinding()]
param(
    [string]$RootPath = 'D:\SERENITY-HMS',
    [string]$ReportPath = "$env:TEMP\serenity-hms-validation-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt",
    [switch]$SkipFlutter,
    [switch]$SkipDocker
)

$ErrorActionPreference = 'Continue'
$RootPath = [IO.Path]::GetFullPath($RootPath)
if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
    throw "Project root not found: $RootPath"
}

$report = [System.Collections.Generic.List[string]]::new()
function Section([string]$title) {
    $report.Add('')
    $report.Add(('=' * 76))
    $report.Add($title)
    $report.Add(('=' * 76))
}
function Run-Check([string]$title, [string]$command, [scriptblock]$action) {
    Section $title
    $report.Add("COMMAND: $command")
    try {
        $output = & $action 2>&1
        foreach ($line in @($output)) {
            if ($null -ne $line) { $report.Add([string]$line) }
        }
        $report.Add("EXIT_CODE: $LASTEXITCODE")
    } catch {
        $report.Add("ERROR: $($_.Exception.Message)")
    }
}

Push-Location $RootPath
try {
    Section 'SERENITY HMS VALIDATION'
    $report.Add("Timestamp: $(Get-Date -Format o)")
    $report.Add("Root: $RootPath")
    $report.Add('This script runs tests and validation commands; it does not edit source files intentionally.')
    $report.Add('Build tools may create or update their own caches/artifacts.')

    Run-Check 'GO TESTS' 'go test ./...' {
        if (-not (Get-Command go -ErrorAction SilentlyContinue)) { throw 'Go CLI not found.' }
        go test ./...
    }

    Run-Check 'GO VET' 'go vet ./...' {
        if (-not (Get-Command go -ErrorAction SilentlyContinue)) { throw 'Go CLI not found.' }
        go vet ./...
    }

    if (-not $SkipFlutter) {
        $mobile = Join-Path $RootPath 'apps\customer-mobile'
        if (Test-Path -LiteralPath (Join-Path $mobile 'pubspec.yaml')) {
            Push-Location $mobile
            try {
                Run-Check 'FLUTTER ANALYZE' 'flutter analyze' {
                    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Flutter CLI not found.' }
                    flutter analyze
                }
                Run-Check 'FLUTTER TESTS' 'flutter test' {
                    flutter test
                }
            } finally { Pop-Location }
        } else {
            Section 'FLUTTER CHECKS'
            $report.Add('SKIPPED: apps\customer-mobile\pubspec.yaml not found.')
        }
    }

    if (-not $SkipDocker) {
        if ((Get-Command docker -ErrorAction SilentlyContinue) -and (Test-Path -LiteralPath (Join-Path $RootPath 'docker-compose.yml'))) {
            Run-Check 'DOCKER COMPOSE CONFIG' 'docker compose config --quiet' {
                docker compose config --quiet
            }
        } else {
            Section 'DOCKER COMPOSE CONFIG'
            $report.Add('SKIPPED: Docker CLI or docker-compose.yml not found.')
        }
    }

    Section 'WEB APP MANIFEST STATUS'
    foreach ($rel in @(
        'apps\landing-page\package.json',
        'apps\commander-web\package.json',
        'apps\staff-portal\package.json'
    )) {
        $report.Add(('{0}: {1}' -f $rel, $(if (Test-Path -LiteralPath (Join-Path $RootPath $rel)) {'FOUND'} else {'MISSING'})))
    }

    Section 'SUMMARY'
    $report.Add('Review each EXIT_CODE and any compiler/test errors above.')
    $report.Add('This report intentionally excludes .env contents and secrets.')
} finally {
    Pop-Location
}

$report | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Host "`nValidation finished." -ForegroundColor Cyan
Write-Host "Report: $ReportPath" -ForegroundColor Green
Write-Host "`n===== REPORT =====" -ForegroundColor Cyan
$report | Select-Object -First 220
if ($report.Count -gt 220) {
    Write-Host "`nFull report is longer. Open it with: notepad `"$ReportPath`"" -ForegroundColor Yellow
}
