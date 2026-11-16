#!/usr/bin/env bash
# sdais.sh — launch an SDAIS agent role with a specific tool and model
# Run from the project root (the directory that contains sdais/prompts/).
#
# Interactive mode loops: after each agent session ends the menu is shown
# again so you can pick the next workflow step without re-running the script.

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./sdais.sh                          interactive menu (loops until quit)
       ./sdais.sh <tool> <model> <role> [msg]  direct launch (msg defaults to "Please begin.")
       ./sdais.sh -h | --help             this help

Interactive menu (no arguments):
  Lists all roles in workflow order with the recommended model per tool and
  prompts for a menu code to launch the next step:
    C01–C12  Claude    X01–X12  Codex    G01–G12  Gemini    O01–O12  Ollama
  e.g. C01 = Claude RequirementsEngineer, G07 = Gemini Generator; q quits.
  Override default models with SDAIS_<TOOL>_REASONING / SDAIS_<TOOL>_CODING,
  e.g. SDAIS_OLLAMA_CODING=devstral:24b ./sdais.sh

Examples per role (use high-reasoning models for spec/audit, high-coding for synthesis):
  ./sdais.sh claude  claude-opus-5-5    RequirementsEngineer
  ./sdais.sh claude  claude-opus-5-5    TransformationEngineer
  ./sdais.sh claude  claude-opus-5-5    SemanticAuditor
  ./sdais.sh claude  claude-opus-5-5    Architect
  ./sdais.sh claude  claude-sonnet-5-5  Grounder
  ./sdais.sh claude  claude-sonnet-5-5  Analyzer
  ./sdais.sh claude  claude-sonnet-5-5  Generator
  ./sdais.sh claude  claude-opus-5-5    Reviewer
  ./sdais.sh claude  claude-sonnet-5-5  Refiner
  ./sdais.sh claude  claude-sonnet-5-5  Transformation
  ./sdais.sh claude  claude-opus-5-5    SecurityAuditor
  ./sdais.sh claude  claude-sonnet-5-5  TestGenerator

Alternative tools:
  ./sdais.sh ollama  qwen3-coder:30b    Generator
  ./sdais.sh codex   gpt-6.1-sol        Generator
  ./sdais.sh gemini  gemini-3.8-flash   Generator

Role names are accepted in CamelCase or kebab-case (e.g. SemanticAuditor or semantic-auditor).
EOF
}

# --- Interactive menu --------------------------------------------------------
#
# Roles in workflow order with their model tier:
#   R = high reasoning (spec, architecture, audit, review)
#   C = high coding    (grounding, synthesis, refinement, tests)
MENU_ROLES=(RequirementsEngineer TransformationEngineer SemanticAuditor Architect
            Grounder Analyzer Generator Reviewer Refiner Transformation
            SecurityAuditor TestGenerator)
MENU_TIERS=(R R R R C C C R C C R C)

MENU_TOOLS=(claude codex gemini ollama)
MENU_PREFIXES=(C X G O)
MENU_LABELS=(Claude Codex Gemini Ollama)

# Recommended models per tool and tier (state: 2026-11).
# Override any of them via environment, e.g. SDAIS_GEMINI_CODING=gemini-3.1-pro-preview.
CLAUDE_REASONING="${SDAIS_CLAUDE_REASONING:-claude-opus-5-5}"
CLAUDE_CODING="${SDAIS_CLAUDE_CODING:-claude-sonnet-5-5}"
CODEX_REASONING="${SDAIS_CODEX_REASONING:-gpt-6.1-sol}"
CODEX_CODING="${SDAIS_CODEX_CODING:-gpt-6-luna}"
GEMINI_REASONING="${SDAIS_GEMINI_REASONING:-gemini-4-argon}"
GEMINI_CODING="${SDAIS_GEMINI_CODING:-gemini-3.8-flash}"
OLLAMA_REASONING="${SDAIS_OLLAMA_REASONING:-gpt-oss:20b}"
OLLAMA_CODING="${SDAIS_OLLAMA_CODING:-qwen3-coder:30b}"

# model_for <tool> <tier>
model_for() {
    case "$1:$2" in
        claude:R) echo "$CLAUDE_REASONING" ;;
        claude:C) echo "$CLAUDE_CODING" ;;
        codex:R)  echo "$CODEX_REASONING" ;;
        codex:C)  echo "$CODEX_CODING" ;;
        gemini:R) echo "$GEMINI_REASONING" ;;
        gemini:C) echo "$GEMINI_CODING" ;;
        ollama:R) echo "$OLLAMA_REASONING" ;;
        ollama:C) echo "$OLLAMA_CODING" ;;
    esac
}

print_menu() {
    local r t code
    printf '\nSDAIS — select a role, tool and model\n\n'
    printf '%-24s' "Role"
    for t in "${!MENU_TOOLS[@]}"; do
        printf '%-22s' "${MENU_LABELS[$t]}"
    done
    printf '\n'
    printf '%-24s' "----"
    for t in "${!MENU_TOOLS[@]}"; do
        printf '%-22s' "------"
    done
    printf '\n'
    for r in "${!MENU_ROLES[@]}"; do
        printf '%-24s' "${MENU_ROLES[$r]}"
        for t in "${!MENU_TOOLS[@]}"; do
            code="$(printf '%s%02d' "${MENU_PREFIXES[$t]}" $((r + 1)))"
            printf '%-22s' "$code $(model_for "${MENU_TOOLS[$t]}" "${MENU_TIERS[$r]}")"
        done
        printf '\n'
    done
    printf '\nModels can be overridden via SDAIS_<TOOL>_REASONING / SDAIS_<TOOL>_CODING.\n\n'
}

# select_from_menu — sets TOOL, MODEL and ROLE from the user's menu code.
select_from_menu() {
    local input code prefix num t r

    print_menu
    while true; do
        if ! read -r -p "Next step — enter a menu code (e.g. C01, q to quit): " input; then
            echo >&2
            exit 1
        fi
        code="$(echo "$input" | tr '[:lower:]' '[:upper:]' | tr -d '[:space:]')"
        if [[ "$code" == "Q" || "$code" == "QUIT" ]]; then
            exit 0
        fi
        if [[ "$code" =~ ^([A-Z])([0-9]{1,2})$ ]]; then
            prefix="${BASH_REMATCH[1]}"
            num=$((10#${BASH_REMATCH[2]}))
            for t in "${!MENU_PREFIXES[@]}"; do
                if [[ "${MENU_PREFIXES[$t]}" == "$prefix" ]] \
                    && (( num >= 1 && num <= ${#MENU_ROLES[@]} )); then
                    r=$((num - 1))
                    TOOL="${MENU_TOOLS[$t]}"
                    ROLE="${MENU_ROLES[$r]}"
                    MODEL="$(model_for "$TOOL" "${MENU_TIERS[$r]}")"
                    echo "→ ./sdais.sh $TOOL $MODEL $ROLE"
                    return 0
                fi
            done
        fi
        echo "Invalid code '$input'. Use C01–C12, X01–X12, G01–G12 or O01–O12."
    done
}

# --- Helpers -----------------------------------------------------------------

PROMPTS_DIR="sdais/prompts"

# Convert CamelCase role name to lowercase-hyphenated prompt filename.
#   RequirementsEngineer → requirements-engineer
#   SemanticAuditor      → semantic-auditor
camel_to_kebab() {
    echo "$1" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//'
}

# Quote a value as a TOML basic string for Codex's --config option.
toml_string() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\b'/\\b}"
    value="${value//$'\f'/\\f}"
    value="${value//$'\t'/\\t}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\n'/\\n}"
    printf '"%s"' "$value"
}

# resolve_prompt <role> — prints the prompt file path or exits with an error.
resolve_prompt() {
    local role="$1"
    local prompt_file="$PROMPTS_DIR/$(camel_to_kebab "$role").md"
    if [[ ! -f "$prompt_file" ]]; then
        prompt_file="$PROMPTS_DIR/$role.md"
    fi
    if [[ ! -f "$prompt_file" ]]; then
        echo "error: no prompt found for role '$role'" >&2
        echo "" >&2
        echo "Available roles:" >&2
        for f in "$PROMPTS_DIR"/*.md; do
            printf "  %s\n" "$(basename "$f" .md)"
        done >&2
        exit 1
    fi
    echo "$prompt_file"
}

# launch_agent <tool> <model> <role> [initial_message] — runs the agent and returns when done.
launch_agent() {
    local tool="$1" model="$2" role="$3" initial_message="${4:-Please begin.}"
    local prompt_file system_prompt

    prompt_file="$(resolve_prompt "$role")"
    system_prompt="$(cat "$prompt_file")"

    case "$tool" in
        claude)
            claude --model "$model" --append-system-prompt "$system_prompt" "$initial_message"
            ;;
        ollama)
            # 'ollama run' has no --system flag; build a temporary named model
            # from a Modelfile with the SYSTEM instruction, then delete it.
            local tmp_model="sdais-$$"
            local tmp_file
            tmp_file="$(mktemp)"
            {
                printf 'FROM %s\n' "$model"
                printf 'SYSTEM """\n%s\n"""\n' "$system_prompt"
            } > "$tmp_file"
            printf 'Creating temporary Ollama model "%s"…\n' "$tmp_model" >&2
            ollama create "$tmp_model" -f "$tmp_file" > /dev/null
            rm -f "$tmp_file"
            ollama run "$tmp_model" || true
            ollama rm "$tmp_model" > /dev/null 2>&1 || true
            ;;
        codex)
            # Codex has no --system-prompt flag. Supply the role as additional
            # developer instructions while retaining Codex's built-in instructions.
            codex --model "$model" \
                --config "developer_instructions=$(toml_string "$system_prompt")" \
                "$initial_message"
            ;;
        gemini)
            # Verify --system-instruction is the correct flag for your Gemini CLI version.
            gemini --model "$model" --system-instruction "$system_prompt"
            ;;
        *)
            echo "error: unsupported tool '$tool'" >&2
            echo "" >&2
            echo "Supported tools: claude, ollama, codex, gemini" >&2
            echo "To add a tool, edit the 'case' block in this script." >&2
            exit 1
            ;;
    esac
}

# --- Entry point -------------------------------------------------------------

if [[ ! -d "$PROMPTS_DIR" ]]; then
    echo "error: sdais/prompts/ not found — run ./sdais.sh from the project root." >&2
    exit 1
fi

# ask_initial_message — prompts for an optional opening message.
# Prints the message; defaults to "Please begin." on empty input.
ask_initial_message() {
    local msg
    printf 'Initial message (Enter for "Please begin.", or type a rework instruction): '
    if ! read -r msg; then
        echo >&2
        exit 1
    fi
    if [[ -z "$msg" ]]; then
        echo "Please begin."
    else
        echo "$msg"
    fi
}

if [[ $# -eq 0 ]]; then
    # Interactive loop: show menu → run agent → repeat until 'q'.
    while true; do
        select_from_menu
        INITIAL_MSG="$(ask_initial_message)"
        launch_agent "$TOOL" "$MODEL" "$ROLE" "$INITIAL_MSG" || true
        printf '\nAgent session ended. Returning to menu…\n'
    done
elif [[ $# -eq 3 ]]; then
    launch_agent "$1" "$2" "$3"
elif [[ $# -eq 4 ]]; then
    launch_agent "$1" "$2" "$3" "$4"
elif [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    usage
    exit 0
else
    usage >&2
    exit 1
fi
