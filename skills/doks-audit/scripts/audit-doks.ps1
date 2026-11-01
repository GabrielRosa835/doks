param(
    [Parameter(Position = 0)]
    [string]$TargetRoot = "."
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TargetRoot)) {
    Write-Output "[ERROR] Path not found: $TargetRoot"
    exit 1
}

$DocsRoot = (Resolve-Path $TargetRoot).Path
if ((Split-Path $DocsRoot -Leaf) -ne "docs" -and (Test-Path (Join-Path $DocsRoot "docs"))) {
    $DocsRoot = (Resolve-Path (Join-Path $DocsRoot "docs")).Path
}

if (-not (Test-Path $DocsRoot -PathType Container)) {
    Write-Output "[ERROR] /docs directory not found at $DocsRoot"
    exit 1
}

$Issues = [System.Collections.Generic.List[string]]::new()
$Warnings = [System.Collections.Generic.List[string]]::new()

$CoreSummaryDirs = @(
    "architecture",
    "decisions",
    "pending",
    "pending/resolved",
    "requisites/system",
    "requisites/user",
    "history"
)

$EntryRegex = [regex]'^\*\s+\*\*\[([^\]]+)\]\(\./([^\)]+)\)\*\*:\s*(.+)$'
$LastUpdatedRegex = [regex]'\*\*Last Updated\*\*:\s*(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2})'
$HistoryHeaderRegex = [regex]'(?m)^#\s+History:\s*(\d{2}/\d{2}/\d{4})\s*$'
$HistoryFileRegex = [regex]'^\d{4}-\d{2}-\d{2}\.md$'

# 1. Check doc-guide.md
$DocGuide = Join-Path $DocsRoot "doc-guide.md"
if (-not (Test-Path $DocGuide -PathType Leaf)) {
    $Issues.Add("Missing root docs/doc-guide.md")
} else {
    $GuideText = Get-Content $DocGuide -Raw -Encoding UTF8
    if (-not $LastUpdatedRegex.IsMatch($GuideText)) {
        $Issues.Add("docs/doc-guide.md: Missing or malformed '**Last Updated**: DD/MM/YYYY HH:mm'")
    }
}

# 2. Walk all directories in DOCS_ROOT for summary.md rules
$AllDirs = @((Get-Item $DocsRoot)) + @(Get-ChildItem -Path $DocsRoot -Directory -Recurse)
foreach ($Dir in $AllDirs) {
    $RelDir = $Dir.FullName.Substring($DocsRoot.Length).TrimStart('\', '/').Replace('\', '/')
    $RelDisplay = if ([string]::IsNullOrEmpty($RelDir)) { "docs" } else { "docs/$RelDir" }

    $Items = @(Get-ChildItem -Path $Dir.FullName | Where-Object { -not $_.Name.StartsWith(".") } | Select-Object -ExpandProperty Name)
    $NonMetaItems = @($Items | Where-Object { $_ -ne "summary.md" -and $_ -ne "template.md" })

    $NeedsSummary = (-not [string]::IsNullOrEmpty($RelDir)) -and (($CoreSummaryDirs -contains $RelDir) -or ($Items.Count -ge 5))
    $SummaryFile = Join-Path $Dir.FullName "summary.md"

    if ($NeedsSummary -and -not (Test-Path $SummaryFile -PathType Leaf)) {
        $Issues.Add("${RelDisplay}: Missing required summary.md (core topic or >=5 items)")
        continue
    }

    if (Test-Path $SummaryFile -PathType Leaf) {
        $Lines = Get-Content $SummaryFile -Encoding UTF8
        $IndexedTargets = [System.Collections.Generic.HashSet[string]]::new()
        $LineNum = 0
        foreach ($Line in $Lines) {
            $LineNum++
            $Trimmed = $Line.Trim()
            if (-not $Trimmed.StartsWith("*")) { continue }

            $Match = $EntryRegex.Match($Trimmed)
            if (-not $Match.Success) {
                $Issues.Add("${RelDisplay}/summary.md:${LineNum}: Entry does not match '* **[name](./name)**: description' format")
                continue
            }

            $DisplayName = $Match.Groups[1].Value
            $TargetClean = $Match.Groups[2].Value.TrimEnd('/')
            $Desc = $Match.Groups[3].Value.Trim()

            if ($DisplayName -ne $TargetClean) {
                $Warnings.Add("${RelDisplay}/summary.md:${LineNum}: Display name '$DisplayName' differs from target '$TargetClean'")
            }
            if ($TargetClean -eq "summary.md" -or $TargetClean -eq "template.md") {
                $Issues.Add("${RelDisplay}/summary.md:${LineNum}: Must not list '$TargetClean' inside summary.md")
            }
            [void]$IndexedTargets.Add($TargetClean)

            if (-not (Test-Path (Join-Path $Dir.FullName $TargetClean))) {
                $Issues.Add("${RelDisplay}/summary.md:${LineNum}: Broken link to non-existent './$TargetClean'")
            }

            $DescLen = $Desc.Length
            if ($DescLen -gt 500) {
                $Issues.Add("${RelDisplay}/summary.md:${LineNum} ($TargetClean): Summary exceeds 500-char hard limit ($DescLen chars)")
            } elseif ($DescLen -lt 200 -or $DescLen -gt 300) {
                $Warnings.Add("${RelDisplay}/summary.md:${LineNum} ($TargetClean): Summary length is $DescLen chars (preferred range: 200-300, max 500)")
            }
        }

        foreach ($Item in ($NonMetaItems | Sort-Object)) {
            if (-not $IndexedTargets.Contains($Item)) {
                $Issues.Add("${RelDisplay}: Item '$Item' exists on disk but is missing from summary.md")
            }
        }
    }
}

# 3. Check numbered sequences and mutable document timestamps
function Test-Sequence {
    param(
        [string]$Prefix,
        [string[]]$Folders
    )
    $Seen = @{}
    $Regex = [regex]"^${Prefix}_(\d{3})-[a-z0-9-]+\.md$"
    $MaxNum = 0

    foreach ($Folder in $Folders) {
        if (-not (Test-Path $Folder -PathType Container)) { continue }
        $Files = Get-ChildItem -Path $Folder -File | Sort-Object Name
        foreach ($F in $Files) {
            if ($F.Name -eq "summary.md" -or $F.Name -eq "template.md") { continue }
            $RelF = "docs/" + $F.FullName.Substring($DocsRoot.Length).TrimStart('\', '/').Replace('\', '/')
            $M = $Regex.Match($F.Name)
            if (-not $M.Success) {
                $Issues.Add("${RelF}: Filename does not match '${Prefix}_XXX-short-name.md'")
                continue
            }
            $NumStr = $M.Groups[1].Value
            $Num = [int]$NumStr
            if ($Seen.ContainsKey($Num)) {
                $Issues.Add("Duplicate ${Prefix}_${NumStr} ID in $RelF and $($Seen[$Num])")
            }
            $Seen[$Num] = $RelF
            if ($Num -gt $MaxNum) { $MaxNum = $Num }

            $Text = Get-Content $F.FullName -Raw -Encoding UTF8
            if (-not $LastUpdatedRegex.IsMatch($Text)) {
                $Issues.Add("${RelF}: Missing or malformed '**Last Updated**: DD/MM/YYYY HH:mm'")
            }
        }
    }

    if ($MaxNum -gt 0) {
        $Missing = @()
        for ($i = 1; $i -le $MaxNum; $i++) {
            if (-not $Seen.ContainsKey($i)) {
                $Missing += ("{0}_{1:D3}" -f $Prefix, $i)
            }
        }
        if ($Missing.Count -gt 0) {
            $Warnings.Add("$Prefix sequence has gaps: missing $($Missing -join ', ')")
        }
    }
}

Test-Sequence -Prefix "DEC" -Folders @((Join-Path $DocsRoot "decisions"))
Test-Sequence -Prefix "PEN" -Folders @((Join-Path $DocsRoot "pending"), (Join-Path $DocsRoot "pending\resolved"))
Test-Sequence -Prefix "SRQ" -Folders @((Join-Path $DocsRoot "requisites\system"))
Test-Sequence -Prefix "URQ" -Folders @((Join-Path $DocsRoot "requisites\user"))

# 4. Check architecture mutable timestamps
$ArchDir = Join-Path $DocsRoot "architecture"
if (Test-Path $ArchDir -PathType Container) {
    $ArchFiles = Get-ChildItem -Path $ArchDir -File -Recurse | Where-Object { $_.Extension -eq ".md" -and $_.Name -ne "summary.md" -and $_.Name -ne "template.md" }
    foreach ($F in $ArchFiles) {
        $RelF = "docs/" + $F.FullName.Substring($DocsRoot.Length).TrimStart('\', '/').Replace('\', '/')
        $Text = Get-Content $F.FullName -Raw -Encoding UTF8
        if (-not $LastUpdatedRegex.IsMatch($Text)) {
            $Issues.Add("${RelF}: Missing or malformed '**Last Updated**: DD/MM/YYYY HH:mm'")
        }
    }
}

# 5. Check history filenames and headers
$HistDir = Join-Path $DocsRoot "history"
if (Test-Path $HistDir -PathType Container) {
    $HistFiles = Get-ChildItem -Path $HistDir -File | Sort-Object Name
    foreach ($F in $HistFiles) {
        if ($F.Name -eq "summary.md" -or $F.Name -eq "template.md") { continue }
        $RelF = "docs/" + $F.FullName.Substring($DocsRoot.Length).TrimStart('\', '/').Replace('\', '/')
        if (-not $HistoryFileRegex.IsMatch($F.Name)) {
            $Issues.Add("${RelF}: History filename must use inverted date 'YYYY-MM-DD.md'")
        } else {
            $Parts = $F.BaseName.Split('-')
            $ExpectedDate = "$($Parts[2])/$($Parts[1])/$($Parts[0])"
            $Text = Get-Content $F.FullName -Raw -Encoding UTF8
            $HM = $HistoryHeaderRegex.Match($Text)
            if (-not $HM.Success) {
                $Issues.Add("${RelF}: Missing '# History: DD/MM/YYYY' header")
            } elseif ($HM.Groups[1].Value -ne $ExpectedDate) {
                $Issues.Add("${RelF}: Header date '$($HM.Groups[1].Value)' does not match filename date '$ExpectedDate'")
            }
        }
    }
}

Write-Output "=== Doks Audit Report ($DocsRoot) ==="
Write-Output "Errors:   $($Issues.Count)"
Write-Output "Warnings: $($Warnings.Count)"

if ($Issues.Count -gt 0) {
    Write-Output "`n[ERRORS]"
    foreach ($I in $Issues) {
        Write-Output "  - $I"
    }
}

if ($Warnings.Count -gt 0) {
    Write-Output "`n[WARNINGS]"
    foreach ($W in $Warnings) {
        Write-Output "  - $W"
    }
}

if ($Issues.Count -eq 0 -and $Warnings.Count -eq 0) {
    Write-Output "`nAll checks passed! The /docs knowledge base strictly conforms to Doks rules."
}

if ($Issues.Count -gt 0) { exit 1 } else { exit 0 }
