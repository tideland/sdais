#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
FORCE=0
VERSION=""

usage() {
    cat <<'EOF'
Usage: scripts/build-release.sh [--force] vX.Y.Z

Runs the repository checks, builds the complete SDAIS distribution under
dist/, verifies it by installing and updating temporary projects, and prints
its SHA-256 checksum.
EOF
}

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) FORCE=1; shift ;;
        -h|--help) usage; exit 0 ;;
        -*) fail "unknown option: $1" ;;
        *)
            [ -z "$VERSION" ] || fail "unexpected argument: $1"
            VERSION=$1
            shift ;;
    esac
done

[ -n "$VERSION" ] || { usage >&2; exit 1; }
[[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] ||
    fail "version must have the form vX.Y.Z: $VERSION"

grep -Fq -- "- **Version:** $VERSION" "$REPO_ROOT/SDAIS.md" ||
    fail "SDAIS.md does not declare $VERSION"
grep -Fq -- "**Version:** $VERSION" "$REPO_ROOT/README.md" ||
    fail "README.md does not declare $VERSION"
grep -Fq -- "SDAIS_VERSION=\"$VERSION\"" "$REPO_ROOT/install.sh" ||
    fail "install.sh does not declare $VERSION"
grep -Fq -- "SDAIS_VERSION=\"$VERSION\"" "$REPO_ROOT/update.sh" ||
    fail "update.sh does not declare $VERSION"
grep -Fq -- "## [$VERSION]" "$REPO_ROOT/CHANGELOG.md" ||
    fail "CHANGELOG.md has no $VERSION entry"
for guide in "$REPO_ROOT"/docs/*.md; do
    grep -Fq -- "**Version:** $VERSION" "$guide" ||
        fail "${guide#"$REPO_ROOT/"} does not declare $VERSION"
done

DIST_DIR="$REPO_ROOT/dist"
ARCHIVE="$DIST_DIR/sdais-$VERSION.tgz"
if [ -e "$ARCHIVE" ] && [ "$FORCE" -ne 1 ]; then
    fail "$ARCHIVE already exists; pass --force to replace it"
fi

"$REPO_ROOT/scripts/check.sh"

STAGE=$(mktemp -d "${TMPDIR:-/tmp}/sdais-release-build.XXXXXX")
cleanup() {
    rm -rf "$STAGE"
}
trap cleanup EXIT

ENTRIES=(
    README.md
    CHANGELOG.md
    LICENSE
    SDAIS.md
    install.sh
    update.sh
    sdais.sh
    docs
    scaffold
)

for entry in "${ENTRIES[@]}"; do
    cp -pR "$REPO_ROOT/$entry" "$STAGE/"
done

BUILT="$STAGE/sdais-$VERSION.tgz"
(
    cd "$STAGE"
    if tar --help 2>&1 | grep -q -- '--no-xattrs'; then
        COPYFILE_DISABLE=1 tar --no-xattrs -czf "$BUILT" "${ENTRIES[@]}"
    else
        COPYFILE_DISABLE=1 tar -czf "$BUILT" "${ENTRIES[@]}"
    fi
)

"$REPO_ROOT/scripts/verify-release.sh" "$BUILT"

mkdir -p "$DIST_DIR"
if [ "$FORCE" -eq 1 ]; then
    rm -f "$ARCHIVE"
fi
mv "$BUILT" "$ARCHIVE"

if command -v shasum >/dev/null 2>&1; then
    CHECKSUM=$(shasum -a 256 "$ARCHIVE")
else
    CHECKSUM=$(sha256sum "$ARCHIVE")
fi

echo "Release archive written: $ARCHIVE"
echo "$CHECKSUM"
