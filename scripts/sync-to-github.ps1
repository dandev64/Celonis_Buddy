# sync-to-github.ps1
# Run this after using /celonis-scrape to refresh any course docs.
# It detects changed files, updates CHANGELOG.md, commits, and pushes.
#
# Usage:
#   cd C:\Users\daniel.jan.p.medado\Documents\celonis-buddy
#   .\scripts\sync-to-github.ps1
#
# Optional flag: -DryRun (shows what would be committed without doing it)

param(
    [switch]$DryRun
)

Set-Location $PSScriptRoot\..

# ── 1. Find changed doc files ────────────────────────────────────────────────
$gitStatus = git status --porcelain docs/ 2>&1
$changed = @()
$added   = @()

foreach ($line in $gitStatus) {
    if ($line -match '^\s*M\s+(.+)') { $changed += $Matches[1].Trim() }
    if ($line -match '^\s*\?\?\s+(.+)') { $added += $Matches[1].Trim() }
}

if ($changed.Count -eq 0 -and $added.Count -eq 0) {
    Write-Host "No doc changes detected. Nothing to commit." -ForegroundColor Yellow
    exit 0
}

Write-Host "Changed files:" -ForegroundColor Cyan
$changed | ForEach-Object { Write-Host "  ~ $_" -ForegroundColor Yellow }
$added   | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green }

# ── 2. Build CHANGELOG entry ─────────────────────────────────────────────────
$date      = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$allFiles  = $changed + $added

$entry = "## $date`n`n"
if ($added.Count -gt 0) {
    $entry += "### New`n"
    $added | ForEach-Object { $entry += "- $_`n" }
    $entry += "`n"
}
if ($changed.Count -gt 0) {
    $entry += "### Updated`n"
    $changed | ForEach-Object { $entry += "- $_`n" }
    $entry += "`n"
}

$changelogPath = "CHANGELOG.md"
$existing = if (Test-Path $changelogPath) { Get-Content $changelogPath -Raw } else { "" }

# Avoid duplicate entry for same date
if ($existing -notmatch [regex]::Escape("## $date")) {
    $newChangelog = "# Changelog`n`n$entry" + ($existing -replace "^# Changelog`n`n?", "")
    if (-not $DryRun) {
        Set-Content $changelogPath $newChangelog -Encoding UTF8
        Write-Host "CHANGELOG.md updated." -ForegroundColor Green
    } else {
        Write-Host "`n[DryRun] Would prepend to CHANGELOG.md:`n$entry" -ForegroundColor Magenta
    }
}

# ── 3. Commit and push ───────────────────────────────────────────────────────
$fileList = ($allFiles | ForEach-Object { Split-Path $_ -Leaf }) -join ", "
$commitMsg = "docs: update $fileList [$timestamp]"

if ($DryRun) {
    Write-Host "`n[DryRun] Would run:" -ForegroundColor Magenta
    Write-Host "  git add docs/ CHANGELOG.md"
    Write-Host "  git commit -m `"$commitMsg`""
    Write-Host "  git push"
    exit 0
}

git add docs/ CHANGELOG.md
git commit -m $commitMsg
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPushed successfully. Colleagues' Claude.ai Project will pick up the changes." -ForegroundColor Green
} else {
    Write-Host "`nPush failed. Check git remote config." -ForegroundColor Red
    exit 1
}
