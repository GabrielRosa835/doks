---
name: doks
description: Scaffolds, navigates, and maintains the Doks topic-driven /docs knowledge base (architecture, decisions DEC_XXX, pending PEN_XXX, system/user requisites SRQ_XXX/URQ_XXX, daily history YYYY-MM-DD.md, and summary.md indexers). Use when initializing /docs in a project, recording or updating decisions/requisites/pending items/architecture specs, resolving pending items, or auditing documentation summaries.
---

# Doks — Document Keeper Skill

**Doks** organizes project knowledge into a mutable, current-state `/docs` hierarchy backed by fast `summary.md` lookup indexers and a daily chronological audit trail (`docs/history/YYYY-MM-DD.md`).

---

## Directory Layout

```text
docs/
├── doc-guide.md
├── architecture/
│   ├── summary.md
│   └── overview.md
├── decisions/
│   ├── template.md
│   ├── summary.md
│   └── DEC_001-example-decision.md
├── pending/
│   ├── template.md
│   ├── summary.md
│   ├── PEN_001-example-open-question.md
│   └── resolved/
│       └── summary.md
├── requisites/
│   ├── template.md
│   ├── system/
│   │   ├── summary.md
│   │   └── SRQ_001-example-system-requisite.md
│   └── user/
│       ├── summary.md
│       └── URQ_001-example-user-requisite.md
└── history/
    ├── template.md
    ├── summary.md
    └── YYYY-MM-DD.md
```

---

## Workflow 1: Initialize `/docs` in a Project

When asked to initialize or scaffold Doks in a project:

1. **Copy Base Templates**: Use the reference files in this skill's `resources/` directory to create:
   - `docs/doc-guide.md` (from `resources/doc-guide.md`, setting `**Last Updated**` to current `DD/MM/YYYY HH:mm`)
   - `docs/decisions/template.md` (from `resources/decisions-template.md`)
   - `docs/pending/template.md` (from `resources/pending-template.md`)
   - `docs/requisites/template.md` (from `resources/requisites-template.md`)
   - `docs/history/template.md` (from `resources/history-template.md`)
2. **Create Initial `summary.md` Indexers**:
   - `docs/architecture/summary.md`
   - `docs/decisions/summary.md`
   - `docs/pending/summary.md` (including the `* **[resolved](./resolved)**: ...` entry)
   - `docs/pending/resolved/summary.md`
   - `docs/requisites/system/summary.md`
   - `docs/requisites/user/summary.md`
   - `docs/history/summary.md`
3. **Create Initial Architecture & History Entries**:
   - Optionally scaffold `docs/architecture/overview.md` if the codebase or user context already defines the architecture, and index it in `docs/architecture/summary.md`.
   - Create today's `docs/history/YYYY-MM-DD.md` recording the initialization of the `/docs` knowledge base, and add its 200–300 character summary to `docs/history/summary.md`.

---

## Workflow 2: Create or Update a Topic Document

### A. Architectural Decision (`DEC_XXX`)
1. Check `docs/decisions/summary.md` for the highest `DEC_XXX` ID and increment by 1 (zero-padded to 3 digits, e.g., `DEC_001`).
2. Create `docs/decisions/DEC_XXX-[short-name].md` following `docs/decisions/template.md`.
3. Add or update the entry in `docs/decisions/summary.md` (200–300 chars preferred, max 500 chars).
4. Record the change in `docs/history/YYYY-MM-DD.md` and update `docs/history/summary.md`.

### B. Pending Item (`PEN_XXX`) & Resolution
1. **To Create**: Check both `docs/pending/summary.md` and `docs/pending/resolved/summary.md` for the highest `PEN_XXX` ID so IDs are never reused. Create `docs/pending/PEN_XXX-[short-name].md` using `docs/pending/template.md` and index it in `docs/pending/summary.md`.
2. **To Resolve**:
   - Update `**Last Updated**` (`DD/MM/YYYY HH:mm`), set `**Status**: Resolved`, and complete the `### Resolution` section with links to resulting `DEC_XXX`, `SRQ_XXX`, `URQ_XXX`, or `architecture/` files.
   - Move the file from `docs/pending/PEN_XXX-[short-name].md` to `docs/pending/resolved/PEN_XXX-[short-name].md`.
   - Remove its entry from `docs/pending/summary.md` and add a 200–300 character entry to `docs/pending/resolved/summary.md`.
   - Record the resolution in `docs/history/YYYY-MM-DD.md` and update `docs/history/summary.md`.

### C. System or User Requisite (`SRQ_XXX` / `URQ_XXX`)
1. Choose `docs/requisites/system/SRQ_XXX-[short-name].md` or `docs/requisites/user/URQ_XXX-[short-name].md`.
2. Check the corresponding subfolder's `summary.md` for the next 3-digit ID in that sequence.
3. Populate the sections from `docs/requisites/template.md`.
4. Update `docs/requisites/system/summary.md` or `docs/requisites/user/summary.md` (200–300 chars preferred, max 500 chars).
5. Record the change in `docs/history/YYYY-MM-DD.md` and update `docs/history/summary.md`.

### D. Architecture Specification (`docs/architecture/`)
1. Create or update the contextual specification file in `docs/architecture/` with `**Last Updated**: DD/MM/YYYY HH:mm` and `**Related Docs**` links.
2. Add or update its 200–300 character entry in `docs/architecture/summary.md`.
3. If any subdirectory inside `docs/architecture/` reaches 5 or more files/directories, create a `summary.md` inside that subdirectory and link the subdirectory in the parent `summary.md`.
4. Record the change in `docs/history/YYYY-MM-DD.md` and update `docs/history/summary.md`.

---

## Formatting Guardrails Checklist
- [ ] **Content dates**: `DD/MM/YYYY HH:mm` (24-hour clock).
- [ ] **History filenames**: `YYYY-MM-DD.md` (inverted for lexicographical sorting).
- [ ] **`summary.md` entry format**: `* **[filename.md](./filename.md)**: [200–300 chars preferred, max 500 chars]`.
- [ ] **`summary.md` exclusions**: Never list `summary.md` or `template.md` inside `summary.md`.
- [ ] **Cross-references**: Use relative markdown links (e.g., `[`DEC_001`](../decisions/DEC_001-slug.md)`).
