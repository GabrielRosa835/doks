---
name: doks-sync
description: Synchronizes the /docs knowledge base with recent codebase changes or conversation outcomes—creating or updating DEC_XXX decisions, PEN_XXX pending items (or resolving them into pending/resolved/), SRQ_XXX/URQ_XXX requisites, architecture specs, summary.md indexers, and today's docs/history/YYYY-MM-DD.md audit log. Triggered by /doks-sync.
---

# `/doks-sync` — Synchronize Documentation & History

Use this skill at the end of a feature, refactor, or design discussion (or whenever the user runs `/doks-sync`) to capture new knowledge into `/docs`.

## Steps

1. **Identify Changes to Record**:
   - Inspect the current conversation and/or `git status` / `git diff` to identify:
     - **Architectural or technical decisions** taken -> `docs/decisions/DEC_XXX-[short-name].md`
     - **Deferred questions or investigations** -> `docs/pending/PEN_XXX-[short-name].md`
     - **Previously open `PEN_XXX` items now resolved** -> Move to `docs/pending/resolved/` and set `**Status**: Resolved`
     - **New or updated requirements** -> `docs/requisites/system/SRQ_XXX-[short-name].md` or `docs/requisites/user/URQ_XXX-[short-name].md`
     - **Module boundary or architecture changes** -> `docs/architecture/*.md`

2. **Read Topic `summary.md` First**:
   - Read the relevant topic's `summary.md` (`decisions/summary.md`, `pending/summary.md`, `pending/resolved/summary.md`, `requisites/system/summary.md`, `requisites/user/summary.md`, `architecture/summary.md`) to find existing docs to update in-place or determine the next zero-padded 3-digit ID (`001`–`999`).

3. **Apply Mutable Updates & Update `summary.md`**:
   - Set `**Last Updated**: DD/MM/YYYY HH:mm` (24-hour clock) on every created or modified mutable document.
   - Add or update each document's entry in its folder's `summary.md` using:
     `* **[filename.md](./filename.md)**: [200–300 character summary (max 500 chars) explaining what the document or directory covers.]`

4. **Record in `docs/history/YYYY-MM-DD.md`**:
   - Create or append to today's `docs/history/YYYY-MM-DD.md` under a proximity header (`## [HH:mm] - [Session / Group Title]`) with `### Actions & Documentation Updates` and `### Decisions & Outcomes`.
   - Update `docs/history/summary.md` with a 200–300 character summary for today's history file.

5. **Run Audit Verification**:
   - Run the platform-appropriate audit script ([audit-doks.sh](../doks-audit/scripts/audit-doks.sh) on Linux/macOS or [audit-doks.ps1](../doks-audit/scripts/audit-doks.ps1) on Windows) to verify 100% compliance.
