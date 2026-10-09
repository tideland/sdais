#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/sdais-line-counter-test.XXXXXX")
PROJECT="$TEST_ROOT/project"
TEST_HOME="$TEST_ROOT/home"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

mkdir -p "$TEST_HOME"
HOME="$TEST_HOME" "$REPO_ROOT/examples/line-counter/bootstrap.sh" \
    "$PROJECT" --rows 10 --malformed 2 >/dev/null

cmp "$REPO_ROOT/examples/line-counter/sdais/gspec/v1/idea.md" \
    "$PROJECT/sdais/gspec/v1/idea.md"
cmp "$REPO_ROOT/examples/line-counter/sdais/library/csv-records/v1/format.md" \
    "$PROJECT/sdais/library/csv-records/v1/format.md"

grep -Fxq 'id,name,email,amount,created_at' < <(head -1 "$PROJECT/data/records.csv") ||
    fail "generated CSV header does not match the adopted library"
rows=$(($(wc -l < "$PROJECT/data/records.csv") - 1))
[ "$rows" -eq 10 ] || fail "expected 10 generated data rows, found $rows"
grep -Fq 'sdais/library/csv-records/v1/format.md' \
    "$PROJECT/sdais/gspec/v1/idea.md" || fail "fixture prose did not adopt its library"
[ ! -e "$REPO_ROOT/scaffold/sdais/library/csv-records/v1/format.md" ] ||
    fail "example-specific library leaked into the universal scaffold"

echo "line-counter example test passed"
