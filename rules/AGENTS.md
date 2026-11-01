# Doks — Project Documentation Rules

When working in a repository that uses the **Doks** `/docs` structure (identified by `/docs/doc-guide.md` or the `/docs/{architecture,decisions,pending,requisites,history}` topic folders), adhere to these rules whenever reading or modifying project documentation:

## 1. Fast Discovery First (`summary.md`)
- Before reading multiple individual files inside `/docs`, read the topic's `summary.md` indexer (`docs/architecture/summary.md`, `docs/decisions/summary.md`, `docs/pending/summary.md`, `docs/requisites/system/summary.md`, `docs/requisites/user/summary.md`, or `docs/history/summary.md`) to locate the exact document you need.
- Never inspect every file in a topic folder blindly when a `summary.md` exists.

## 2. Five Core Documentation Topics
- **`docs/architecture/`**: High-level contextual specifications of modules, boundaries, responsibilities, and dependencies. No rigid `template.md`, indexed by `docs/architecture/summary.md`.
- **`docs/decisions/` (`DEC_XXX-[short-name].md`)**: Architectural and technical decisions. Follows `docs/decisions/template.md` and is indexed in `docs/decisions/summary.md`.
- **`docs/pending/` (`PEN_XXX-[short-name].md`)**: Open architectural questions, deferred decisions, or technical investigations. Follows `docs/pending/template.md` and is indexed in `docs/pending/summary.md`. When resolved, set **Status** to `Resolved`, fill out **Resolution**, move the file into `docs/pending/resolved/`, and transfer its index entry from `docs/pending/summary.md` to `docs/pending/resolved/summary.md`.
- **`docs/requisites/` (`SRQ_XXX` & `URQ_XXX`)**: Divided into `docs/requisites/system/SRQ_XXX-[short-name].md` (System Requirements) and `docs/requisites/user/URQ_XXX-[short-name].md` (User Requirements). Both follow `docs/requisites/template.md`, maintain independent zero-padded 3-digit sequences, and maintain separate `summary.md` indexers in `system/` and `user/`.
- **`docs/history/` (`YYYY-MM-DD.md`)**: Chronological daily audit log of meaningful documentation updates, architectural decisions, and session outcomes. Follows `docs/history/template.md` and is indexed in `docs/history/summary.md`.

## 3. Mutability, Timestamps & Naming Conventions
- **Mutable Living Documents**: Documents in `architecture/`, `decisions/`, `pending/`, and `requisites/` represent the **current state** of the project. Update them in-place as the system evolves rather than leaving stale specifications behind.
- **Content Timestamps (`DD/MM/YYYY HH:mm`)**: Inside document content, always format dates as `DD/MM/YYYY` and times in 24-hour `HH:mm` (`23:59`) format (e.g., `**Last Updated**: 01/11/2026 11:50`).
- **Filesystem Dates (`YYYY-MM-DD`)**: In file and directory names (such as `docs/history/YYYY-MM-DD.md`), always invert dates to `YYYY-MM-DD` for natural lexicographical sorting.
- **Numbered Prefixes**: Use `<PREFIX>_<XXX>-[short-name].md` where `<PREFIX>` is `DEC`, `PEN`, `SRQ`, or `URQ`, `<XXX>` is a zero-padded 3-digit integer (`001`–`999`) unique within that prefix's sequence (checking `pending/resolved/` as well for `PEN`), and `[short-name]` is lowercase `kebab-case`.

## 4. Mandatory Synchronization (`summary.md` & `history/`)
Whenever you create, significantly update, or resolve any document in `/docs`:
1. **Update `Last Updated`**: Set `**Last Updated**: DD/MM/YYYY HH:mm` on every modified mutable document.
2. **Maintain `summary.md`**:
   - Ensure a `summary.md` file exists in all core topic directories and in any `/docs` subdirectory containing **5 or more files/directories**.
   - List every document and subdirectory except `template.md` and `summary.md` itself.
   - Format each entry as:
     `* **[filename.md](./filename.md)**: [200–300 character summary (max 500 chars) explaining what the document or directory covers.]`
3. **Log in `docs/history/YYYY-MM-DD.md`**:
   - Add or append to today's history file under a proximity header (`## [HH:mm] - [Session / Group Title]`) with `### Actions & Documentation Updates` and `### Decisions & Outcomes`, and keep `docs/history/summary.md` updated.
