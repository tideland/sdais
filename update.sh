#!/usr/bin/env bash
# SDAIS update script — v0.13.0
# Usage: update.sh [--from <old-version>]
#
# Run from your project root. Replaces scaffold files (prompts, templates,
# AGENTS.md, sdais/SDAIS.md) with the current SDAIS version while leaving
# all project content untouched.
#
# Project content left untouched:
#   sdais/rsf/v*/  — items with sequence number 0001 or higher
#   sdais/rar/v*/  — findings with sequence number 0001 or higher
#   sdais/trs/v*/  — transformation hypotheses
#   sdais/cdf/v*/  — change definition files
#   sdais/adf/v*/  — architecture definition files
#   sdais/library/** — every project-owned reference library and version
#   All source code outside sdais/

set -euo pipefail

SDAIS_VERSION="v0.13.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FROM_VERSION=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --from) FROM_VERSION="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
    esac
done

# Verify we are in an SDAIS project root
if [ ! -f AGENTS.md ] || [ ! -d sdais/prompts ]; then
    echo "error: run from the root of an SDAIS project (AGENTS.md and sdais/prompts/ must exist)" >&2
    exit 1
fi

echo "SDAIS — updating scaffold to $SDAIS_VERSION${FROM_VERSION:+ (from $FROM_VERSION)}"

# Extract project name from AGENTS.md first heading
PROJECT=$(head -1 AGENTS.md | sed 's/^# AGENTS — //')

# Save the Custom Agents Extension block
CUSTOM_BLOCK=$(mktemp)
awk '/<!-- BEGIN: Custom Agents Extension -->/,/<!-- END: Custom Agents Extension -->/' AGENTS.md > "$CUSTOM_BLOCK"

# Locate scaffold. The v0.13.0 distribution archive expands beside scaffold/,
# so the unpacked directory takes precedence over the archive itself.
TGZ="$SCRIPT_DIR/sdais-$SDAIS_VERSION.tgz"

if [ -d "$SCRIPT_DIR/scaffold" ]; then
    cp -p "$SCRIPT_DIR/scaffold/AGENTS.md" AGENTS.md
    cp -rp "$SCRIPT_DIR/scaffold/sdais/prompts/." sdais/prompts/
    # Update 0000-template files only — never touch numbered project files
    find "$SCRIPT_DIR/scaffold/sdais/rsf" -name "*-0000-template.md" | while read -r src; do
        rel="${src#$SCRIPT_DIR/scaffold/}"
        dir="$(dirname "$rel")"
        mkdir -p "$dir"
        cp -p "$src" "$rel"
    done
    # rar/ templates are optional — absent in scaffolds that predate them
    if [ -d "$SCRIPT_DIR/scaffold/sdais/rar" ]; then
        find "$SCRIPT_DIR/scaffold/sdais/rar" -name "*-0000-template.md" | while read -r src; do
            rel="${src#$SCRIPT_DIR/scaffold/}"
            dir="$(dirname "$rel")"
            mkdir -p "$dir"
            cp -p "$src" "$rel"
        done
    fi
elif [ -f "$TGZ" ]; then
    # Backward-compatible support for a scaffold-only distribution archive.
    # Extract only managed scaffold files, skipping project content.
    tar tf "$TGZ" | grep -E '(^AGENTS\.md$|prompts/|rsf/v[0-9]+/[a-z]+-0000-template|rar/v[0-9]+/f-0000-template)' \
        | xargs tar xzf "$TGZ"
else
    echo "error: neither $TGZ nor $SCRIPT_DIR/scaffold/ found" >&2
    rm -f "$CUSTOM_BLOCK"
    exit 1
fi

# v0.12.0 renamed Designer to Architect. Remove the obsolete managed prompt so
# upgraded projects expose only current roles; project-authored files are untouched.
rm -f sdais/prompts/designer.md

# Update sdais/SDAIS.md
cp "$SCRIPT_DIR/SDAIS.md" sdais/SDAIS.md

# Refresh the sdais launcher in ~/.local/bin/
LOCAL_BIN="$HOME/.local/bin"
if [ -f "$LOCAL_BIN/sdais" ]; then
    cp "$SCRIPT_DIR/sdais.sh" "$LOCAL_BIN/sdais"
    chmod +x "$LOCAL_BIN/sdais"
fi

# Restore project name in the new AGENTS.md
tmp=$(mktemp)
sed "s/<Project Name>/$PROJECT/g" AGENTS.md > "$tmp" && mv "$tmp" AGENTS.md

# Re-inject Custom Agents Extension block
tmp=$(mktemp)
awk -v block="$CUSTOM_BLOCK" '
    /<!-- BEGIN: Custom Agents Extension -->/ {
        while ((getline line < block) > 0) print line
        skip = 1; next
    }
    /<!-- END: Custom Agents Extension -->/ { skip = 0; next }
    !skip { print }
' AGENTS.md > "$tmp" && mv "$tmp" AGENTS.md
rm -f "$CUSTOM_BLOCK"

echo "Done."
echo "  sdais/prompts/ refreshed"
echo "  obsolete designer.md prompt removed"
echo "  *-0000-template.md files refreshed"
echo "  AGENTS.md regenerated (Custom Agents Extension preserved)"
echo "  sdais/SDAIS.md updated"
[ -f "$LOCAL_BIN/sdais" ] && echo "  $LOCAL_BIN/sdais updated"
echo ""
echo "Project content (library, gspec, tspec, rsf, rar, trs, cdf, adf, source files) left unchanged."
echo "Review sdais/SDAIS.md for workflow changes introduced in $SDAIS_VERSION."
