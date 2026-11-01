---
name: doks-audit
description: Audits and validates the /docs knowledge base against Doks conventions (verifying summary.md presence, 200–300 character summary lengths, 500-char hard limits, unindexed or broken file links, DEC/PEN/SRQ/URQ ID sequences, DD/MM/YYYY HH:mm content timestamps, and YYYY-MM-DD.md history logs). Triggered by /doks-audit or when the user asks to review, validate, or audit documentation.
---

# `/doks-audit` — Audit & Validate the Doks Knowledge Base

Use this skill to verify that the repository's `/docs` directory adheres to all **Doks** structural and formatting rules, and to fix any issues found.

## Steps

1. **Run the Automated Audit Script**:
   Execute the platform-appropriate audit script against the workspace root (or `docs/` path):
   - **Linux / macOS (Bash)**:
     [audit-doks.sh](./scripts/audit-doks.sh)
   - **Windows (PowerShell)**:
     [audit-doks.ps1](./scripts/audit-doks.ps1)

2. **Review Semantic & Structural Findings**:
   In addition to the script's structural checks (missing `summary.md`, character counts outside 200–300 or >500, broken links, missing `**Last Updated**: DD/MM/YYYY HH:mm`, duplicate/gap IDs, or mismatched `YYYY-MM-DD.md` history headers), check:
   - Whether any resolved `PEN_XXX` items are still sitting in `docs/pending/` instead of `docs/pending/resolved/`.
   - Whether recent documentation changes were logged in `docs/history/YYYY-MM-DD.md`.

3. **Report & Offer Fixes**:
   - Present a clear summary of any **Errors** and **Warnings**.
   - Offer to automatically fix any formatting discrepancies, missing `summary.md` entries, or out-of-range summary descriptions.
