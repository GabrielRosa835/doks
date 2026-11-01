#!/usr/bin/env bash
set -euo pipefail

TARGET_ROOT="${1:-.}"
DOCS_DIR="${TARGET_ROOT%/}/docs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RES_DIR="$(cd "${SCRIPT_DIR}/../../doks/resources" && pwd)"

NOW_CONTENT="$(date '+%d/%m/%Y %H:%M')"
TODAY_CONTENT="$(date '+%d/%m/%Y')"
NOW_TIME="$(date '+%H:%M')"
TODAY_FILE="$(date '+%Y-%m-%d')"

mkdir -p \
  "${DOCS_DIR}/architecture" \
  "${DOCS_DIR}/decisions" \
  "${DOCS_DIR}/pending/resolved" \
  "${DOCS_DIR}/requisites/system" \
  "${DOCS_DIR}/requisites/user" \
  "${DOCS_DIR}/history"

# 1. Copy doc-guide.md with current timestamp if not present
if [[ ! -f "${DOCS_DIR}/doc-guide.md" ]]; then
  sed "s|DD/MM/YYYY HH:mm|${NOW_CONTENT}|g" "${RES_DIR}/doc-guide.md" > "${DOCS_DIR}/doc-guide.md"
  echo "Created ${DOCS_DIR}/doc-guide.md"
fi

# 2. Copy topic templates if not present
[[ ! -f "${DOCS_DIR}/decisions/template.md" ]] && cp "${RES_DIR}/decisions-template.md" "${DOCS_DIR}/decisions/template.md" && echo "Created ${DOCS_DIR}/decisions/template.md"
[[ ! -f "${DOCS_DIR}/pending/template.md" ]] && cp "${RES_DIR}/pending-template.md" "${DOCS_DIR}/pending/template.md" && echo "Created ${DOCS_DIR}/pending/template.md"
[[ ! -f "${DOCS_DIR}/requisites/template.md" ]] && cp "${RES_DIR}/requisites-template.md" "${DOCS_DIR}/requisites/template.md" && echo "Created ${DOCS_DIR}/requisites/template.md"
[[ ! -f "${DOCS_DIR}/history/template.md" ]] && cp "${RES_DIR}/history-template.md" "${DOCS_DIR}/history/template.md" && echo "Created ${DOCS_DIR}/history/template.md"

# 3. Create initial summary.md indexers if not present
if [[ ! -f "${DOCS_DIR}/architecture/summary.md" ]]; then
  cat > "${DOCS_DIR}/architecture/summary.md" <<'EOF'
# Architecture Summary

_No architecture specifications recorded yet. Add contextual specification files in this directory and index them here with a 200–300 character summary._
EOF
  echo "Created ${DOCS_DIR}/architecture/summary.md"
fi

if [[ ! -f "${DOCS_DIR}/decisions/summary.md" ]]; then
  cat > "${DOCS_DIR}/decisions/summary.md" <<'EOF'
# Decisions Summary

_No architectural decisions recorded yet. Create `DEC_XXX-[short-name].md` files following `template.md` and index them here with a 200–300 character summary._
EOF
  echo "Created ${DOCS_DIR}/decisions/summary.md"
fi

if [[ ! -f "${DOCS_DIR}/pending/summary.md" ]]; then
  cat > "${DOCS_DIR}/pending/summary.md" <<'EOF'
# Pending Summary

* **[resolved](./resolved)**: Archive directory containing previously open pending items (PEN_XXX) that have since been investigated and resolved into architectural decisions, system/user requisites, or concrete codebase implementations.
EOF
  echo "Created ${DOCS_DIR}/pending/summary.md"
fi

if [[ ! -f "${DOCS_DIR}/pending/resolved/summary.md" ]]; then
  cat > "${DOCS_DIR}/pending/resolved/summary.md" <<'EOF'
# Resolved Pending Items Summary

_No resolved pending items yet. When a `PEN_XXX` document in `docs/pending/` is resolved, move it into this directory and add its 200–300 character summary entry here._
EOF
  echo "Created ${DOCS_DIR}/pending/resolved/summary.md"
fi

if [[ ! -f "${DOCS_DIR}/requisites/system/summary.md" ]]; then
  cat > "${DOCS_DIR}/requisites/system/summary.md" <<'EOF'
# System Requisites Summary

_No system requisites recorded yet. Create `SRQ_XXX-[short-name].md` files following `../template.md` and index them here with a 200–300 character summary._
EOF
  echo "Created ${DOCS_DIR}/requisites/system/summary.md"
fi

if [[ ! -f "${DOCS_DIR}/requisites/user/summary.md" ]]; then
  cat > "${DOCS_DIR}/requisites/user/summary.md" <<'EOF'
# User Requisites Summary

_No user requisites recorded yet. Create `URQ_XXX-[short-name].md` files following `../template.md` and index them here with a 200–300 character summary._
EOF
  echo "Created ${DOCS_DIR}/requisites/user/summary.md"
fi

# 4. Create initial history entry and history/summary.md if not present
HISTORY_FILE="${DOCS_DIR}/history/${TODAY_FILE}.md"
if [[ ! -f "${HISTORY_FILE}" ]]; then
  cat > "${HISTORY_FILE}" <<EOF
# History: ${TODAY_CONTENT}

## ${NOW_TIME} - Initialize Doks Knowledge Base

### Actions & Documentation Updates
- **Documentation Guide ([\`doc-guide.md\`](../doc-guide.md))**: Initialized the Doks documentation guide defining the five core topics (\`architecture\`, \`decisions\`, \`pending\`, \`requisites\`, \`history\`), mutability rules, timestamp conventions, and \`summary.md\` indexers.
- **Topic Hierarchy & Templates**: Scaffolded topic directories, \`template.md\` guides, and initial \`summary.md\` lookup indexers across all topics.

### Decisions & Outcomes
- **Doks Adoption**: Standardized project documentation around a topic-driven, mutable knowledge base backed by daily chronological audit logs.
EOF
  echo "Created ${HISTORY_FILE}"
fi

if [[ ! -f "${DOCS_DIR}/history/summary.md" ]]; then
  cat > "${DOCS_DIR}/history/summary.md" <<EOF
# History Summary

* **[${TODAY_FILE}.md](./${TODAY_FILE}.md)**: Initialized the Doks topic-driven /docs knowledge base, including doc-guide.md, topic templates for decisions (DEC_XXX), pending items (PEN_XXX), system/user requisites (SRQ_XXX/URQ_XXX), and summary.md lookup indexers.
EOF
  echo "Created ${DOCS_DIR}/history/summary.md"
fi

echo "Doks initialization complete at ${DOCS_DIR}"
