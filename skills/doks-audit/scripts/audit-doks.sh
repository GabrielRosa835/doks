#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
if [[ ! -d "$TARGET" ]]; then
  echo "[ERROR] Path not found: $TARGET"
  exit 1
fi

DOCS_ROOT="$(cd "$TARGET" && pwd)"
if [[ "$(basename "$DOCS_ROOT")" != "docs" && -d "$DOCS_ROOT/docs" ]]; then
  DOCS_ROOT="$DOCS_ROOT/docs"
fi

if [[ ! -d "$DOCS_ROOT" ]]; then
  echo "[ERROR] /docs directory not found at $DOCS_ROOT"
  exit 1
fi

ISSUES=()
WARNINGS=()

add_issue() { ISSUES+=("$1"); }
add_warning() { WARNINGS+=("$1"); }

has_last_updated() {
  grep -Eq '\*\*Last Updated\*\*:[[:space:]]*[0-9]{2}/[0-9]{2}/[0-9]{4}[[:space:]]+[0-9]{2}:[0-9]{2}' "$1"
}

is_core_summary_dir() {
  local rel="$1"
  case "$rel" in
    architecture|decisions|pending|pending/resolved|requisites/system|requisites/user|history)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# 1. Check doc-guide.md
if [[ ! -f "$DOCS_ROOT/doc-guide.md" ]]; then
  add_issue "Missing root docs/doc-guide.md"
elif ! has_last_updated "$DOCS_ROOT/doc-guide.md"; then
  add_issue "docs/doc-guide.md: Missing or malformed '**Last Updated**: DD/MM/YYYY HH:mm'"
fi

# 2. Walk all directories in DOCS_ROOT for summary.md rules
while IFS= read -r -d '' dpath; do
  rel_dir="${dpath#"$DOCS_ROOT"}"
  rel_dir="${rel_dir#/}"
  [[ -z "$rel_dir" ]] && rel_display="docs" || rel_display="docs/$rel_dir"

  # Collect immediate non-hidden entries
  items=()
  non_meta_items=()
  while IFS= read -r -d '' entry; do
    ename="$(basename "$entry")"
    [[ "$ename" == .* ]] && continue
    items+=("$ename")
    if [[ "$ename" != "summary.md" && "$ename" != "template.md" ]]; then
      non_meta_items+=("$ename")
    fi
  done < <(find "$dpath" -mindepth 1 -maxdepth 1 -print0 | sort -z)

  needs_summary=false
  if [[ -n "$rel_dir" ]]; then
    if is_core_summary_dir "$rel_dir" || (( ${#items[@]} >= 5 )); then
      needs_summary=true
    fi
  fi

  summary_file="$dpath/summary.md"
  if $needs_summary && [[ ! -f "$summary_file" ]]; then
    add_issue "$rel_display: Missing required summary.md (core topic or >=5 items)"
    continue
  fi

  if [[ -f "$summary_file" ]]; then
    declare -A indexed_targets=()
    line_num=0
    while IFS= read -r line || [[ -n "$line" ]]; do
      line_num=$((line_num + 1))
      trimmed="${line#"${line%%[![:space:]]*}"}"
      [[ "$trimmed" != \** ]] && continue

      entry_re='^\*[[:space:]]+\*\*\[([^]]+)\]\(\./([^)]+)\)\*\*:[[:space:]]*(.+)$'
      if [[ "$trimmed" =~ $entry_re ]]; then
        display_name="${BASH_REMATCH[1]}"
        target_name="${BASH_REMATCH[2]}"
        desc="${BASH_REMATCH[3]}"
        desc="${desc%"${desc##*[![:space:]]}"}"
        target_clean="${target_name%/}"

        if [[ "$display_name" != "$target_clean" ]]; then
          add_warning "$rel_display/summary.md:$line_num: Display name '$display_name' differs from target '$target_clean'"
        fi
        if [[ "$target_clean" == "summary.md" || "$target_clean" == "template.md" ]]; then
          add_issue "$rel_display/summary.md:$line_num: Must not list '$target_clean' inside summary.md"
        fi
        indexed_targets["$target_clean"]=1

        if [[ ! -e "$dpath/$target_clean" ]]; then
          add_issue "$rel_display/summary.md:$line_num: Broken link to non-existent './$target_clean'"
        fi

        desc_len=${#desc}
        if (( desc_len > 500 )); then
          add_issue "$rel_display/summary.md:$line_num ($target_clean): Summary exceeds 500-char hard limit ($desc_len chars)"
        elif (( desc_len < 200 || desc_len > 300 )); then
          add_warning "$rel_display/summary.md:$line_num ($target_clean): Summary length is $desc_len chars (preferred range: 200-300, max 500)"
        fi
      else
        add_issue "$rel_display/summary.md:$line_num: Entry does not match '* **[name](./name)**: description' format"
      fi
    done < "$summary_file"

    for item in "${non_meta_items[@]}"; do
      if [[ -z "${indexed_targets[$item]:-}" ]]; then
        add_issue "$rel_display: Item '$item' exists on disk but is missing from summary.md"
      fi
    done
    unset indexed_targets
  fi
done < <(find "$DOCS_ROOT" -type d -print0 | sort -z)

# 3. Check numbered sequences and mutable document timestamps
check_sequence() {
  local prefix="$1"
  shift
  local folders=("$@")
  declare -A seen_ids=()
  local max_num=0

  for folder in "${folders[@]}"; do
    [[ ! -d "$folder" ]] && continue
    while IFS= read -r -d '' fpath; do
      fname="$(basename "$fpath")"
      [[ "$fname" == "summary.md" || "$fname" == "template.md" ]] && continue
      rel_f="docs/${fpath#"$DOCS_ROOT/"}"

      if [[ "$fname" =~ ^${prefix}_([0-9]{3})-[a-z0-9-]+\.md$ ]]; then
        num_str="${BASH_REMATCH[1]}"
        num=$((10#$num_str))
        if [[ -n "${seen_ids[$num]:-}" ]]; then
          add_issue "Duplicate ${prefix}_${num_str} ID in $rel_f and ${seen_ids[$num]}"
        fi
        seen_ids[$num]="$rel_f"
        (( num > max_num )) && max_num=$num

        if ! has_last_updated "$fpath"; then
          add_issue "$rel_f: Missing or malformed '**Last Updated**: DD/MM/YYYY HH:mm'"
        fi
      else
        add_issue "$rel_f: Filename does not match '${prefix}_XXX-short-name.md'"
      fi
    done < <(find "$folder" -mindepth 1 -maxdepth 1 -type f -print0 | sort -z)
  done

  if (( max_num > 0 )); then
    local missing=()
    for ((i = 1; i <= max_num; i++)); do
      if [[ -z "${seen_ids[$i]:-}" ]]; then
        printf -v padded "%s_%03d" "$prefix" "$i"
        missing+=("$padded")
      fi
    done
    if (( ${#missing[@]} > 0 )); then
      add_warning "$prefix sequence has gaps: missing ${missing[*]}"
    fi
  fi
  unset seen_ids
}

check_sequence "DEC" "$DOCS_ROOT/decisions"
check_sequence "PEN" "$DOCS_ROOT/pending" "$DOCS_ROOT/pending/resolved"
check_sequence "SRQ" "$DOCS_ROOT/requisites/system"
check_sequence "URQ" "$DOCS_ROOT/requisites/user"

# 4. Check architecture mutable timestamps
if [[ -d "$DOCS_ROOT/architecture" ]]; then
  while IFS= read -r -d '' fpath; do
    fname="$(basename "$fpath")"
    [[ "$fname" == "summary.md" || "$fname" == "template.md" || "$fname" != *.md ]] && continue
    rel_f="docs/${fpath#"$DOCS_ROOT/"}"
    if ! has_last_updated "$fpath"; then
      add_issue "$rel_f: Missing or malformed '**Last Updated**: DD/MM/YYYY HH:mm'"
    fi
  done < <(find "$DOCS_ROOT/architecture" -type f -print0 | sort -z)
fi

# 5. Check history filenames and headers
if [[ -d "$DOCS_ROOT/history" ]]; then
  while IFS= read -r -d '' fpath; do
    fname="$(basename "$fpath")"
    [[ "$fname" == "summary.md" || "$fname" == "template.md" ]] && continue
    rel_f="docs/${fpath#"$DOCS_ROOT/"}"
    if [[ "$fname" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})\.md$ ]]; then
      expected_date="${BASH_REMATCH[3]}/${BASH_REMATCH[2]}/${BASH_REMATCH[1]}"
      header_line="$(grep -m 1 -E '^#[[:space:]]+History:' "$fpath" || true)"
      if [[ -z "$header_line" ]]; then
        add_issue "$rel_f: Missing '# History: DD/MM/YYYY' header"
      elif [[ ! "$header_line" =~ ^#[[:space:]]+History:[[:space:]]*([0-9]{2}/[0-9]{2}/[0-9]{4})[[:space:]]*$ ]]; then
        add_issue "$rel_f: Malformed '# History: DD/MM/YYYY' header"
      elif [[ "${BASH_REMATCH[1]}" != "$expected_date" ]]; then
        add_issue "$rel_f: Header date '${BASH_REMATCH[1]}' does not match filename date '$expected_date'"
      fi
    else
      add_issue "$rel_f: History filename must use inverted date 'YYYY-MM-DD.md'"
    fi
  done < <(find "$DOCS_ROOT/history" -mindepth 1 -maxdepth 1 -type f -print0 | sort -z)
fi

echo "=== Doks Audit Report ($DOCS_ROOT) ==="
echo "Errors:   ${#ISSUES[@]}"
echo "Warnings: ${#WARNINGS[@]}"

if (( ${#ISSUES[@]} > 0 )); then
  echo ""
  echo "[ERRORS]"
  for i in "${ISSUES[@]}"; do
    echo "  - $i"
  done
fi

if (( ${#WARNINGS[@]} > 0 )); then
  echo ""
  echo "[WARNINGS]"
  for w in "${WARNINGS[@]}"; do
    echo "  - $w"
  done
fi

if (( ${#ISSUES[@]} == 0 && ${#WARNINGS[@]} == 0 )); then
  echo ""
  echo "All checks passed! The /docs knowledge base strictly conforms to Doks rules."
fi

(( ${#ISSUES[@]} > 0 )) && exit 1 || exit 0
