param(
    [Parameter(Position = 0)]
    [string]$TargetRoot = "."
)

$ErrorActionPreference = "Stop"

$ResolvedRoot = (Resolve-Path $TargetRoot).Path
$DocsDir = Join-Path $ResolvedRoot "docs"
$ResDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..\doks\resources")).Path

$Now = Get-Date
$NowContent = $Now.ToString("dd/MM/yyyy HH:mm")
$TodayContent = $Now.ToString("dd/MM/yyyy")
$NowTime = $Now.ToString("HH:mm")
$TodayFile = $Now.ToString("yyyy-MM-dd")

$Directories = @(
    (Join-Path $DocsDir "architecture"),
    (Join-Path $DocsDir "decisions"),
    (Join-Path $DocsDir "pending\resolved"),
    (Join-Path $DocsDir "requisites\system"),
    (Join-Path $DocsDir "requisites\user"),
    (Join-Path $DocsDir "history")
)

foreach ($Dir in $Directories) {
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }
}

# 1. Copy doc-guide.md with current timestamp if not present
$DocGuidePath = Join-Path $DocsDir "doc-guide.md"
if (-not (Test-Path $DocGuidePath)) {
    $GuideContent = Get-Content (Join-Path $ResDir "doc-guide.md") -Raw -Encoding UTF8
    $GuideContent = $GuideContent.Replace("DD/MM/YYYY HH:mm", $NowContent)
    Set-Content -Path $DocGuidePath -Value $GuideContent -Encoding UTF8 -NoNewline
    Write-Output "Created $DocGuidePath"
}

# 2. Copy topic templates if not present
$Templates = @{
    (Join-Path $DocsDir "decisions\template.md")  = (Join-Path $ResDir "decisions-template.md")
    (Join-Path $DocsDir "pending\template.md")    = (Join-Path $ResDir "pending-template.md")
    (Join-Path $DocsDir "requisites\template.md") = (Join-Path $ResDir "requisites-template.md")
    (Join-Path $DocsDir "history\template.md")    = (Join-Path $ResDir "history-template.md")
}

foreach ($Dest in $Templates.Keys) {
    if (-not (Test-Path $Dest)) {
        Copy-Item -Path $Templates[$Dest] -Destination $Dest
        Write-Output "Created $Dest"
    }
}

# 3. Create initial summary.md indexers if not present
$Summaries = @{
    (Join-Path $DocsDir "architecture\summary.md") = @"
# Architecture Summary

_No architecture specifications recorded yet. Add contextual specification files in this directory and index them here with a 200–300 character summary._
"@
    (Join-Path $DocsDir "decisions\summary.md") = @"
# Decisions Summary

_No architectural decisions recorded yet. Create ``DEC_XXX-[short-name].md`` files following ``template.md`` and index them here with a 200–300 character summary._
"@
    (Join-Path $DocsDir "pending\summary.md") = @"
# Pending Summary

* **[resolved](./resolved)**: Archive directory containing previously open pending items (PEN_XXX) that have since been investigated and resolved into architectural decisions, system/user requisites, or concrete codebase implementations.
"@
    (Join-Path $DocsDir "pending\resolved\summary.md") = @"
# Resolved Pending Items Summary

_No resolved pending items yet. When a ``PEN_XXX`` document in ``docs/pending/`` is resolved, move it into this directory and add its 200–300 character summary entry here._
"@
    (Join-Path $DocsDir "requisites\system\summary.md") = @"
# System Requisites Summary

_No system requisites recorded yet. Create ``SRQ_XXX-[short-name].md`` files following ``../template.md`` and index them here with a 200–300 character summary._
"@
    (Join-Path $DocsDir "requisites\user\summary.md") = @"
# User Requisites Summary

_No user requisites recorded yet. Create ``URQ_XXX-[short-name].md`` files following ``../template.md`` and index them here with a 200–300 character summary._
"@
}

foreach ($SummaryPath in $Summaries.Keys) {
    if (-not (Test-Path $SummaryPath)) {
        Set-Content -Path $SummaryPath -Value ($Summaries[$SummaryPath] + "`n") -Encoding UTF8 -NoNewline
        Write-Output "Created $SummaryPath"
    }
}

# 4. Create initial history entry and history/summary.md if not present
$HistoryFile = Join-Path $DocsDir "history\$TodayFile.md"
if (-not (Test-Path $HistoryFile)) {
    $HistoryContent = @"
# History: $TodayContent

## $NowTime - Initialize Doks Knowledge Base

### Actions & Documentation Updates
- **Documentation Guide ([``doc-guide.md``](../doc-guide.md))**: Initialized the Doks documentation guide defining the five core topics (``architecture``, ``decisions``, ``pending``, ``requisites``, ``history``), mutability rules, timestamp conventions, and ``summary.md`` indexers.
- **Topic Hierarchy & Templates**: Scaffolded topic directories, ``template.md`` guides, and initial ``summary.md`` lookup indexers across all topics.

### Decisions & Outcomes
- **Doks Adoption**: Standardized project documentation around a topic-driven, mutable knowledge base backed by daily chronological audit logs.
"@
    Set-Content -Path $HistoryFile -Value ($HistoryContent + "`n") -Encoding UTF8 -NoNewline
    Write-Output "Created $HistoryFile"
}

$HistorySummary = Join-Path $DocsDir "history\summary.md"
if (-not (Test-Path $HistorySummary)) {
    $HistorySummaryContent = @"
# History Summary

* **[$TodayFile.md](./$TodayFile.md)**: Initialized the Doks topic-driven /docs knowledge base, including doc-guide.md, topic templates for decisions (DEC_XXX), pending items (PEN_XXX), system/user requisites (SRQ_XXX/URQ_XXX), and summary.md lookup indexers.
"@
    Set-Content -Path $HistorySummary -Value ($HistorySummaryContent + "`n") -Encoding UTF8 -NoNewline
    Write-Output "Created $HistorySummary"
}

Write-Output "Doks initialization complete at $DocsDir"
