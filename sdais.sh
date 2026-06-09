#!/usr/bin/env bash
# sdais — launch an SDAIS agent role with a specific tool and model
# Run from the project root (the directory that contains sdais/prompts/).

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: sdais.sh <tool> <model> <role>

Examples per role (use high-reasoning models for spec/audit, high-coding for synthesis):
  sdais.sh claude  claude-opus-4-5    RequirementsEngineer
  sdais.sh claude  claude-opus-4-5    TransformationEngineer
  sdais.sh claude  claude-opus-4-5    SemanticAuditor
  sdais.sh claude  claude-opus-4-5    Designer
  sdais.sh claude  claude-sonnet-4-5  Grounder
  sdais.sh claude  claude-sonnet-4-5  Analyzer
  sdais.sh claude  claude-sonnet-4-5  Generator
  sdais.sh claude  claude-opus-4-5    Reviewer
  sdais.sh claude  claude-sonnet-4-5  Refiner
  sdais.sh claude  claude-sonnet-4-5  Transformation
  sdais.sh claude  claude-opus-4-5    SecurityAuditor
  sdais.sh claude  claude-sonnet-4-5  TestGenerator

Alternative tools:
  sdais.sh ollama  gemma4             Generator
  sdais.sh codex   codex-mini         Generator
  sdais.sh gemini  gemini-2.0-flash   Generator

Role names are accepted in CamelCase or kebab-case (e.g. SemanticAuditor or semantic-auditor).
EOF
}

if [[ $# -ne 3 ]]; then
    usage >&2
    exit 1
fi

TOOL="$1"
MODEL="$2"
ROLE="$3"

PROMPTS_DIR="sdais/prompts"

if [[ ! -d "$PROMPTS_DIR" ]]; then
    echo "error: sdais/prompts/ not found — run sdais from the project root." >&2
    exit 1
fi

# Convert CamelCase role name to lowercase-hyphenated prompt filename.
#   RequirementsEngineer → requirements-engineer
#   SemanticAuditor      → semantic-auditor
camel_to_kebab() {
    echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

# Accept CamelCase (RequirementsEngineer) or kebab-case (requirements-engineer)
PROMPT_FILE="$PROMPTS_DIR/$(camel_to_kebab "$ROLE").md"
if [[ ! -f "$PROMPT_FILE" ]]; then
    PROMPT_FILE="$PROMPTS_DIR/$ROLE.md"
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "error: no prompt found for role '$ROLE'" >&2
    echo "" >&2
    echo "Available roles:" >&2
    for f in "$PROMPTS_DIR"/*.md; do
        printf "  %s\n" "$(basename "$f" .md)"
    done >&2
    exit 1
fi

SYSTEM_PROMPT="$(cat "$PROMPT_FILE")"

case "$TOOL" in
    claude)
        exec claude --model "$MODEL" --append-system-prompt "$SYSTEM_PROMPT" "Please begin."
        ;;
    ollama)
        exec ollama run "$MODEL" --system "$SYSTEM_PROMPT"
        ;;
    codex)
        exec codex --model "$MODEL" --system-prompt "$SYSTEM_PROMPT"
        ;;
    gemini)
        # Verify --system-instruction is the correct flag for your Gemini CLI version.
        exec gemini --model "$MODEL" --system-instruction "$SYSTEM_PROMPT"
        ;;
    *)
        echo "error: unsupported tool '$TOOL'" >&2
        echo "" >&2
        echo "Supported tools: claude, ollama, codex, gemini" >&2
        echo "To add a tool, edit the 'case' block in this script." >&2
        exit 1
        ;;
esac
