#!/usr/bin/env bash
# SDAIS install script — v0.8.0
# Usage: bash install.sh <project-name>
#
# Run from your project root. Creates AGENTS.md and the full sdais/ scaffold.
# Requires: SDAIS.md in the same directory as this script.

set -euo pipefail

SDAIS_VERSION="v0.8.0"
PROJECT="${1:?Usage: bash install.sh <project-name>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY="$(date +%Y-%m-%d)"

echo "SDAIS $SDAIS_VERSION — installing scaffold for: $PROJECT"

# Locate scaffold: tgz takes precedence over scaffold/ directory
TGZ="$SCRIPT_DIR/sdais-$SDAIS_VERSION.tgz"

if [ -f "$TGZ" ]; then
    tar xzf "$TGZ"
elif [ -d "$SCRIPT_DIR/scaffold" ]; then
    cp -rp "$SCRIPT_DIR/scaffold/." .
else
    echo "error: neither $TGZ nor $SCRIPT_DIR/scaffold/ found" >&2
    exit 1
fi

# Copy SDAIS.md into sdais/
cp "$SCRIPT_DIR/SDAIS.md" sdais/SDAIS.md

# Create empty version directories not included in the scaffold
mkdir -p sdais/adf/v1 sdais/res/v1 sdais/cdf/v1

# Substitute placeholders in AGENTS.md
tmp=$(mktemp)
sed "s/<Project Name>/$PROJECT/g" AGENTS.md > "$tmp" && mv "$tmp" AGENTS.md

# Substitute today's date in template files
find sdais/rsf sdais/rar -name "*-template.md" | while read -r f; do
    tmp=$(mktemp)
    sed "s/YYYY-MM-DD/$TODAY/g" "$f" > "$tmp" && mv "$tmp" "$f"
done

echo "Done."
echo "  AGENTS.md"
echo "  sdais/SDAIS.md"
printf "  sdais/prompts/ (%d prompt files)\n" "$(ls sdais/prompts/ | wc -l | tr -d ' ')"
printf "  sdais/rsf/v1/  (%d template files)\n" "$(ls sdais/rsf/v1/ | wc -l | tr -d ' ')"
printf "  sdais/rar/v1/  (%d template files)\n" "$(ls sdais/rar/v1/ | wc -l | tr -d ' ')"
echo ""
echo "Next: author RSF items in sdais/rsf/v1/, then run the SemanticAuditor."
