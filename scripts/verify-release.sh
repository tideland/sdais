#!/usr/bin/env bash

set -euo pipefail

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

checksum() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        sha256sum "$1" | awk '{print $1}'
    fi
}

if [ "$#" -ne 1 ]; then
    echo "Usage: scripts/verify-release.sh <sdais-vX.Y.Z.tgz>" >&2
    exit 1
fi

ARCHIVE_INPUT=$1
[ -f "$ARCHIVE_INPUT" ] || fail "archive not found: $ARCHIVE_INPUT"
ARCHIVE_DIR=$(cd "$(dirname "$ARCHIVE_INPUT")" && pwd)
ARCHIVE="$ARCHIVE_DIR/$(basename "$ARCHIVE_INPUT")"
ARCHIVE_NAME=$(basename "$ARCHIVE")
[[ "$ARCHIVE_NAME" =~ ^sdais-(v[0-9]+\.[0-9]+\.[0-9]+)\.tgz$ ]] ||
    fail "archive name must be sdais-vX.Y.Z.tgz: $ARCHIVE_NAME"
VERSION=${BASH_REMATCH[1]}

VERIFY_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/sdais-release-verify.XXXXXX")
LISTING="$VERIFY_ROOT/listing.txt"
EXTRACTED="$VERIFY_ROOT/extracted"
PROJECT="$VERIFY_ROOT/project"
TEST_HOME="$VERIFY_ROOT/home"

cleanup() {
    rm -rf "$VERIFY_ROOT"
}
trap cleanup EXIT

tar -tzf "$ARCHIVE" > "$LISTING"

while IFS= read -r entry; do
    clean=${entry#./}
    [ -n "$clean" ] || continue
    case "/$clean/" in
        *'/../'*) fail "archive contains path traversal: $entry" ;;
    esac
    [[ "$clean" != /* ]] || fail "archive contains absolute path: $entry"
    case "$clean" in
        README.md|CHANGELOG.md|LICENSE|SDAIS.md|install.sh|update.sh|sdais.sh|\
        docs|docs/|docs/*|scaffold|scaffold/|scaffold/*) ;;
        *) fail "unexpected archive entry: $entry" ;;
    esac
    case "/$clean/" in
        *'/sdais/library/'*) fail "archive contains project library content: $entry" ;;
    esac
done < "$LISTING"

for required in README.md CHANGELOG.md LICENSE SDAIS.md install.sh update.sh \
                sdais.sh scaffold/AGENTS.md \
                scaffold/sdais/prompts/semantic-auditor.md \
                scaffold/sdais/rsf/v1/fr-0000-template.md; do
    grep -Fxq "$required" "$LISTING" || fail "archive is missing $required"
done

mkdir -p "$EXTRACTED" "$PROJECT" "$TEST_HOME"
tar -xzf "$ARCHIVE" -C "$EXTRACTED"
bash -n "$EXTRACTED/install.sh" "$EXTRACTED/update.sh" "$EXTRACTED/sdais.sh"

grep -Fq -- "- **Version:** $VERSION" "$EXTRACTED/SDAIS.md" ||
    fail "archive specification version does not match its filename"
grep -Fq -- "SDAIS_VERSION=\"$VERSION\"" "$EXTRACTED/install.sh" ||
    fail "archive installer version does not match its filename"
grep -Fq -- "SDAIS_VERSION=\"$VERSION\"" "$EXTRACTED/update.sh" ||
    fail "archive updater version does not match its filename"

(
    cd "$PROJECT"
    HOME="$TEST_HOME" "$EXTRACTED/install.sh" "Release Verification" >/dev/null
)
[ -d "$PROJECT/sdais/library" ] || fail "fresh install did not create sdais/library"

mkdir -p "$PROJECT/sdais/library/example/v1" \
         "$PROJECT/sdais/library/example/v2"
printf 'release sentinel v1\n' > "$PROJECT/sdais/library/example/v1/contract.md"
printf 'release sentinel v2\n' > "$PROJECT/sdais/library/example/v2/contract.md"
V1_BEFORE=$(checksum "$PROJECT/sdais/library/example/v1/contract.md")
V2_BEFORE=$(checksum "$PROJECT/sdais/library/example/v2/contract.md")

CUSTOM_TEXT='ReleaseVerifier — preserve this custom agent extension.'
CUSTOM_TMP="$VERIFY_ROOT/custom-agents.tmp"
awk -v custom="$CUSTOM_TEXT" '
    /<!-- END: Custom Agents Extension -->/ { print custom }
    { print }
' "$PROJECT/AGENTS.md" > "$CUSTOM_TMP"
mv "$CUSTOM_TMP" "$PROJECT/AGENTS.md"

(
    cd "$PROJECT"
    HOME="$TEST_HOME" "$EXTRACTED/update.sh" --from v0.0.0 >/dev/null
)

[ "$V1_BEFORE" = "$(checksum "$PROJECT/sdais/library/example/v1/contract.md")" ] ||
    fail "update changed project library v1"
[ "$V2_BEFORE" = "$(checksum "$PROJECT/sdais/library/example/v2/contract.md")" ] ||
    fail "update changed project library v2"
grep -Fq "$CUSTOM_TEXT" "$PROJECT/AGENTS.md" ||
    fail "update did not preserve the Custom Agents Extension"

diff -qr "$EXTRACTED/scaffold/sdais/prompts" "$PROJECT/sdais/prompts" >/dev/null
diff -qr "$EXTRACTED/scaffold/sdais/rsf" "$PROJECT/sdais/rsf" >/dev/null
diff -qr "$EXTRACTED/scaffold/sdais/trs" "$PROJECT/sdais/trs" >/dev/null
cmp "$EXTRACTED/SDAIS.md" "$PROJECT/sdais/SDAIS.md"

echo "Release archive verified: $ARCHIVE_NAME"
echo "  entries: $(wc -l < "$LISTING" | tr -d ' ')"
echo "  SHA-256: $(checksum "$ARCHIVE")"
