---
name: doks-init
description: Scaffolds the Doks topic-driven /docs knowledge base in a project (creating doc-guide.md, architecture/, decisions/, pending/resolved/, requisites/system/, requisites/user/, history/, all template.md and summary.md files, and today's initial history log). Triggered by /doks-init or when the user asks to initialize Doks documentation.
---

# `/doks-init` — Initialize Doks Knowledge Base

Use this skill to scaffold the complete **Doks** `/docs` directory hierarchy in a new or existing project.

## Steps

1. **Run the Scaffolding Script**:
   Execute the platform-appropriate script passing the target workspace root (defaults to `.`):
   - **Linux / macOS (Bash)**:
     [init-doks.sh](./scripts/init-doks.sh)
   - **Windows (PowerShell)**:
     [init-doks.ps1](./scripts/init-doks.ps1)

   *(Both scripts are idempotent, require zero external runtimes, and will not overwrite existing files.)*

2. **Inspect the Project & Offer Initial Extraction**:
   - Check if the repository already has a `README.md`, `GEMINI.md`, `AGENTS.md`, or existing architecture notes.
   - Ask the user if they would like to immediately draft `docs/architecture/overview.md` (and index it in `docs/architecture/summary.md`) or extract initial `DEC_001`, `SRQ_001`, `URQ_001`, or `PEN_001` documents from the existing codebase.

3. **Verify**:
   - Confirm that `docs/doc-guide.md`, all topic folders, `template.md` files, `summary.md` indexers, and today's `docs/history/YYYY-MM-DD.md` entry are in place.
