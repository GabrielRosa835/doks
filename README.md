# Doks

**Doks** is a minimalist AI agent plugin and document keeper that scaffolds, audits, and maintains a topic-driven, mutable `/docs` knowledge base (`architecture`, `decisions`, `pending`, `requisites`, and `history`) with fast `summary.md` indexers.

## Slash Commands & Skills

| Command / Skill | Purpose |
| :--- | :--- |
| **`/doks`** | General document keeper skill and reference for creating, updating, and resolving topic documents (`DEC_XXX`, `PEN_XXX`, `SRQ_XXX`, `URQ_XXX`, `architecture/`, `history/`). |
| **`/doks-init`** | Scaffolds the entire `/docs` directory hierarchy, `doc-guide.md`, topic `template.md` files, `summary.md` indexers, and today's initial `YYYY-MM-DD.md` history log (`init-doks.sh` / `init-doks.ps1`). |
| **`/doks-audit`** | Validates the `/docs` knowledge base against all Doks rules (`summary.md` coverage, 200–300 char target / 500 char max, broken/unindexed links, ID sequences, and `DD/MM/YYYY HH:mm` / `YYYY-MM-DD.md` timestamps) via `audit-doks.sh` / `audit-doks.ps1`. |
| **`/doks-sync`** | Inspects recent conversation outcomes or git changes to create/update topic documents, update `summary.md` indexers, and append to `docs/history/YYYY-MM-DD.md`. |

## Always-On Rules (`rules/AGENTS.md`)

When enabled, Doks injects lightweight rules guiding the agent to:
1. Consult `summary.md` indexers first before reading multiple files in a topic folder.
2. Keep documents in `architecture/`, `decisions/`, `pending/`, and `requisites/` mutable in-place with `**Last Updated**: DD/MM/YYYY HH:mm`.
3. Use inverted `YYYY-MM-DD.md` filenames for `docs/history/` logs.
4. Synchronize `summary.md` (200–300 chars preferred, max 500) and `docs/history/YYYY-MM-DD.md` whenever documentation changes.

## `/docs` Topic Structure

```text
docs/
├── doc-guide.md
├── architecture/
│   ├── summary.md
│   └── overview.md
├── decisions/
│   ├── template.md
│   ├── summary.md
│   └── DEC_001-....md
├── pending/
│   ├── template.md
│   ├── summary.md
│   ├── PEN_001-....md
│   └── resolved/
│       └── summary.md
├── requisites/
│   ├── template.md
│   ├── system/
│   │   ├── summary.md
│   │   └── SRQ_001-....md
│   └── user/
│       ├── summary.md
│       └── URQ_001-....md
└── history/
    ├── template.md
    ├── summary.md
    └── YYYY-MM-DD.md
```

## Installation

### Linux / macOS
```bash
ln -s /path/to/doks ~/.gemini/config/plugins/doks
```

### Windows (PowerShell)
```powershell
New-Item -ItemType SymbolicLink -Path "$HOME\.gemini\config\plugins\doks" -Target "C:\path\to\doks"
```
