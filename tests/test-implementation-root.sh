#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/sdais-implementation-root-test.XXXXXX")
MANAGED="$TEST_ROOT/managed"
LEGACY="$TEST_ROOT/legacy"
TEST_HOME="$TEST_ROOT/home"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

checksum() {
    shasum -a 256 "$1" | awk '{print $1}'
}

[ -f "$REPO_ROOT/scaffold/implementation/.sdais-root" ] ||
    fail "universal scaffold lacks managed-root marker"
[ ! -s "$REPO_ROOT/scaffold/implementation/.sdais-root" ] ||
    fail "scaffold marker is not zero-byte"

mkdir -p "$MANAGED" "$LEGACY" "$TEST_HOME"
(
    cd "$MANAGED"
    HOME="$TEST_HOME" "$REPO_ROOT/install.sh" "Managed Layout Test" >/dev/null
)

[ -d "$MANAGED/implementation" ] || fail "fresh install lacks implementation root"
[ -f "$MANAGED/implementation/.sdais-root" ] || fail "fresh install lacks marker"
[ ! -s "$MANAGED/implementation/.sdais-root" ] || fail "installed marker is not zero-byte"

mkdir -p "$MANAGED/implementation/cmd/tool" "$MANAGED/implementation/internal/core"
printf 'module example.test/tool\n\ngo 1.22\n' > "$MANAGED/implementation/go.mod"
printf 'package main\n' > "$MANAGED/implementation/cmd/tool/main.go"
printf 'package core\n' > "$MANAGED/implementation/internal/core/core.go"
MARKER_BEFORE=$(checksum "$MANAGED/implementation/.sdais-root")
MOD_BEFORE=$(checksum "$MANAGED/implementation/go.mod")
MAIN_BEFORE=$(checksum "$MANAGED/implementation/cmd/tool/main.go")
CORE_BEFORE=$(checksum "$MANAGED/implementation/internal/core/core.go")
(
    cd "$MANAGED"
    HOME="$TEST_HOME" "$REPO_ROOT/update.sh" --from v0.12.2 >/dev/null
)
[ "$MARKER_BEFORE" = "$(checksum "$MANAGED/implementation/.sdais-root")" ] ||
    fail "update changed managed-root marker"
[ "$MOD_BEFORE" = "$(checksum "$MANAGED/implementation/go.mod")" ] ||
    fail "update changed implementation manifest"
[ "$MAIN_BEFORE" = "$(checksum "$MANAGED/implementation/cmd/tool/main.go")" ] ||
    fail "update changed implementation source"
[ "$CORE_BEFORE" = "$(checksum "$MANAGED/implementation/internal/core/core.go")" ] ||
    fail "update changed nested implementation source"
[ ! -e "$MANAGED/go.mod" ] || fail "update moved manifest to project root"

(
    cd "$LEGACY"
    HOME="$TEST_HOME" "$REPO_ROOT/install.sh" "Legacy Layout Test" >/dev/null
)
rm -rf "$LEGACY/implementation"
mkdir -p "$LEGACY/bin" "$LEGACY/internal/core"
printf 'module legacy.test/tool\n\ngo 1.22\n' > "$LEGACY/go.mod"
printf 'legacy binary sentinel\n' > "$LEGACY/bin/tool"
printf 'package core\n' > "$LEGACY/internal/core/core.go"
LEGACY_MOD=$(checksum "$LEGACY/go.mod")
LEGACY_BIN=$(checksum "$LEGACY/bin/tool")
LEGACY_CORE=$(checksum "$LEGACY/internal/core/core.go")
(
    cd "$LEGACY"
    HOME="$TEST_HOME" "$REPO_ROOT/update.sh" --from v0.12.2 >/dev/null
)
[ ! -e "$LEGACY/implementation" ] ||
    fail "update activated managed-root mode in an unmarked legacy project"
[ "$LEGACY_MOD" = "$(checksum "$LEGACY/go.mod")" ] || fail "update changed legacy go.mod"
[ "$LEGACY_BIN" = "$(checksum "$LEGACY/bin/tool")" ] || fail "update changed legacy bin"
[ "$LEGACY_CORE" = "$(checksum "$LEGACY/internal/core/core.go")" ] ||
    fail "update changed legacy internal source"

for prompt in transformation-engineer semantic-auditor architect generator \
              reviewer refiner analyzer transformation security-auditor \
              test-generator; do
    grep -Fq '#implementation-root' "$REPO_ROOT/scaffold/sdais/prompts/$prompt.md" ||
        fail "$prompt prompt does not consume implementation-root contract"
done
for prompt in requirements-engineer grounder; do
    ! grep -Fq '#implementation-root' "$REPO_ROOT/scaffold/sdais/prompts/$prompt.md" ||
        fail "$prompt prompt should remain implementation-root-independent"
done

grep -Fq 'complete transformed target under `implementation/`' "$REPO_ROOT/SDAIS.md" ||
    fail "normative SDAIS-T separate-target rule is missing"
grep -Fq 'never delete|replace the legacy source' \
    "$REPO_ROOT/scaffold/sdais/prompts/transformation.md" ||
    fail "Transformation prompt does not preserve external legacy source"
grep -Fq 'implementation/go.mod' "$REPO_ROOT/docs/GREENFIELD.md" ||
    fail "greenfield guide lacks concrete managed-root example"

echo "implementation root tests passed"
