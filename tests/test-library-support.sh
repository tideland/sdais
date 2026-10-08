#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/sdais-library-test.XXXXXX")
PROJECT_ROOT="$TEST_ROOT/project"
LEGACY_ROOT="$TEST_ROOT/legacy-project"
TEST_HOME="$TEST_ROOT/home"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_file() {
    [ -f "$1" ] || fail "missing file: $1"
}

assert_dir() {
    [ -d "$1" ] || fail "missing directory: $1"
}

mkdir -p "$PROJECT_ROOT" "$TEST_HOME"
(
    cd "$PROJECT_ROOT"
    HOME="$TEST_HOME" "$REPO_ROOT/install.sh" "Library Test"
)

assert_dir "$PROJECT_ROOT/sdais/library"
diff -qr "$REPO_ROOT/scaffold/sdais/prompts" "$PROJECT_ROOT/sdais/prompts"

cp -R "$PROJECT_ROOT" "$LEGACY_ROOT"
rm -rf "$LEGACY_ROOT/sdais/library"
(
    cd "$LEGACY_ROOT"
    HOME="$TEST_HOME" "$REPO_ROOT/update.sh" --from v0.12.2 >/dev/null
)
[ ! -e "$LEGACY_ROOT/sdais/library" ] ||
    fail "update changed a legacy project that had no library root"

mkdir -p \
    "$PROJECT_ROOT/sdais/library/example/v1" \
    "$PROJECT_ROOT/sdais/library/example/v2" \
    "$PROJECT_ROOT/sdais/library/tds/v1"
printf 'contract v1\n' > "$PROJECT_ROOT/sdais/library/example/v1/contract.md"
printf 'contract v2\n' > "$PROJECT_ROOT/sdais/library/example/v2/contract.md"
printf '# TDS\n\n## 8 Workspace and Coordinates\n' > \
    "$PROJECT_ROOT/sdais/library/tds/v1/tds.md"
printf '# Color Contract\n\nThe widget color MUST be blue.\n' > \
    "$PROJECT_ROOT/sdais/library/example/v1/color.md"
CONTRADICTORY_RSF="$TEST_ROOT/fr-0001-color.md"
printf '%s\n' \
    '# FR-0001: Widget color' \
    '- **Libraries:** sdais/library/example/v1/color.md' \
    'The widget color must be red.' > "$CONTRADICTORY_RSF"

V1_BEFORE=$(shasum -a 256 "$PROJECT_ROOT/sdais/library/example/v1/contract.md")
V2_BEFORE=$(shasum -a 256 "$PROJECT_ROOT/sdais/library/example/v2/contract.md")

CUSTOM_TEXT='CustomLibraryAuditor — preserve this exact extension text.'
CUSTOM_TMP="$TEST_ROOT/custom-agents.tmp"
awk -v custom="$CUSTOM_TEXT" '
    /<!-- END: Custom Agents Extension -->/ { print custom }
    { print }
' "$PROJECT_ROOT/AGENTS.md" > "$CUSTOM_TMP"
mv "$CUSTOM_TMP" "$PROJECT_ROOT/AGENTS.md"

(
    cd "$PROJECT_ROOT"
    HOME="$TEST_HOME" "$REPO_ROOT/update.sh" --from v0.12.2
)

[ "$V1_BEFORE" = "$(shasum -a 256 "$PROJECT_ROOT/sdais/library/example/v1/contract.md")" ] ||
    fail "update changed library v1"
[ "$V2_BEFORE" = "$(shasum -a 256 "$PROJECT_ROOT/sdais/library/example/v2/contract.md")" ] ||
    fail "update changed library v2"
grep -Fq "$CUSTOM_TEXT" "$PROJECT_ROOT/AGENTS.md" ||
    fail "update did not preserve Custom Agents Extension"
diff -qr "$REPO_ROOT/scaffold/sdais/prompts" "$PROJECT_ROOT/sdais/prompts"
diff -qr "$REPO_ROOT/scaffold/sdais/rsf" "$PROJECT_ROOT/sdais/rsf"
diff -qr "$REPO_ROOT/scaffold/sdais/trs" "$PROJECT_ROOT/sdais/trs"
cmp "$REPO_ROOT/SDAIS.md" "$PROJECT_ROOT/sdais/SDAIS.md"

for template in "$REPO_ROOT"/scaffold/sdais/rsf/v1/*-0000-template.md \
                "$REPO_ROOT"/scaffold/sdais/trs/v1/*-0000-template.md; do
    source_line=$(grep -n '^- \*\*Source:\*\*' "$template" | cut -d: -f1)
    library_line=$(grep -n '^- \*\*Libraries:\*\*' "$template" | cut -d: -f1)
    [ "$library_line" -eq $((source_line + 1)) ] ||
        fail "Libraries is not immediately after Source in $template"
done

validate_reference() {
    local project=$1
    local reference=$2
    local path=${reference%%#*}
    local anchor=""
    local relative

    if [[ "$reference" == *#* ]]; then
        anchor=${reference#*#}
        [ -n "$anchor" ] || return 1
    fi
    [[ "$path" =~ ^sdais/library/[a-z0-9]+(-[a-z0-9]+)*/v[1-9][0-9]*/.+[^/]$ ]] || return 1
    [[ "$path" != *".."* && "$path" != *"/latest/"* ]] || return 1
    relative=${path#sdais/library/}
    [ -f "$project/sdais/library/$relative" ] || return 1
    iconv -f UTF-8 -t UTF-8 "$project/sdais/library/$relative" >/dev/null 2>&1 || return 1
    if [ -n "$anchor" ]; then
        grep -Eq '^#{1,6}[[:space:]]+8 Workspace and Coordinates[[:space:]]*$' \
            "$project/sdais/library/$relative" || return 1
        [ "$anchor" = "8-workspace-and-coordinates" ] || return 1
    fi
}

validate_reference "$PROJECT_ROOT" \
    'sdais/library/tds/v1/tds.md#8-workspace-and-coordinates' ||
    fail "valid pinned reference rejected"
! validate_reference "$PROJECT_ROOT" 'sdais/library/tds/tds.md' ||
    fail "missing version accepted"
! validate_reference "$PROJECT_ROOT" 'sdais/library/tds/v1/../secret.md' ||
    fail "path escape accepted"
! validate_reference "$PROJECT_ROOT" 'sdais/library/tds/v1/missing.md' ||
    fail "missing file accepted"
! validate_reference "$PROJECT_ROOT" 'sdais/library/tds/v1/tds.md#missing' ||
    fail "missing anchor accepted"

grep -Fq 'RSF, libraries' "$REPO_ROOT/scaffold/sdais/prompts/semantic-auditor.md" ||
    fail "semantic auditor does not cover RSF/library contradiction"
grep -Fq 'MUST be blue' "$PROJECT_ROOT/sdais/library/example/v1/color.md" &&
grep -Fq 'must be red' "$CONTRADICTORY_RSF" &&
grep -Fq -- '-> CONTRADICTORY' "$REPO_ROOT/scaffold/sdais/prompts/semantic-auditor.md" ||
    fail "RSF/library contradiction is not routed to CONTRADICTORY"
grep -Fq 'LIBRARY-UNRESOLVABLE' "$REPO_ROOT/scaffold/sdais/prompts/semantic-auditor.md" ||
    fail "semantic auditor lacks reference-error category"

if rg -n 'sdais/gspec/v1/tds\.md' "$REPO_ROOT" \
    -g '!sdais-v*.tgz' -g '!sdais-v*.tar.gz'; then
    fail "stale TDS source path remains"
fi

echo "library support tests passed"
