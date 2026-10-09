#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

echo "==> Shell syntax"
while IFS= read -r -d '' script; do
    bash -n "$script"
done < <(find "$REPO_ROOT" -type f -name '*.sh' \
    -not -path "$REPO_ROOT/.git/*" \
    -not -path "$REPO_ROOT/dist/*" -print0)

echo "==> Repository tests"
for test_script in "$REPO_ROOT"/tests/test-*.sh; do
    [ -f "$test_script" ] || continue
    bash "$test_script"
done

echo "==> Markdown links and fences"
while IFS= read -r -d '' markdown; do
    while IFS= read -r token; do
        target=${token#']('}
        target=${target%')'}
        target=${target%%#*}
        case "$target" in
            ''|http://*|https://*|mailto:*|'<'*'>') continue ;;
        esac
        base=$(dirname "$markdown")
        [ -e "$base/$target" ] ||
            fail "broken link: ${markdown#"$REPO_ROOT/"} -> $target"
    done < <(rg -o '\]\([^)]+\)' "$markdown" || true)

    fences=$(rg -c '^```' "$markdown" || true)
    fences=${fences:-0}
    [ $((fences % 2)) -eq 0 ] ||
        fail "unbalanced fenced block: ${markdown#"$REPO_ROOT/"}"
done < <(find "$REPO_ROOT" -type f -name '*.md' \
    -not -path "$REPO_ROOT/.git/*" \
    -not -path "$REPO_ROOT/dist/*" -print0)

echo "==> Managed prompt inventory"
prompt_count=$(find "$REPO_ROOT/scaffold/sdais/prompts" -maxdepth 1 \
    -type f -name '*.md' | wc -l | tr -d ' ')
[ "$prompt_count" -eq 12 ] || fail "expected 12 managed prompts, found $prompt_count"

echo "==> Git whitespace"
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_ROOT" diff --check
fi

echo "All checks passed."
