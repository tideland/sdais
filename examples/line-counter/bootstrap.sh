#!/usr/bin/env bash
# Bootstrap the line-counter fixture into a throwaway project directory.
#
# Scaffolds an SDAIS-G project, drops in the fixture prose, and generates a
# CSV of the requested size for the tool under test to read.
#
# Usage: bootstrap.sh <target-dir> [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDAIS_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ROWS=1000
SIZE=""
MALFORMED=0
FORCE=0
TARGET=""

usage() {
    cat <<'EOF'
Usage: bootstrap.sh <target-dir> [options]

Creates an SDAIS-G project for the line-counter fixture and generates a CSV
test file under <target-dir>/data/.

Options:
  --rows N        number of data rows to generate (default: 1000)
  --size BYTES    generate approximately BYTES instead of a row count;
                  accepts a K, M, or G suffix (e.g. 512K, 10M, 1G)
  --malformed N   inject N malformed rows, spread evenly (default: 0)
  --force         replace <target-dir> if it already exists
  -h, --help      show this help

Examples:
  bootstrap.sh /tmp/lc
  bootstrap.sh /tmp/lc --rows 250000 --malformed 5
  bootstrap.sh /tmp/lc --size 100M
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --rows)      ROWS="$2"; SIZE=""; shift 2 ;;
        --size)      SIZE="$2"; shift 2 ;;
        --malformed) MALFORMED="$2"; shift 2 ;;
        --force)     FORCE=1; shift ;;
        -h|--help)   usage; exit 0 ;;
        -*)          echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
        *)
            if [[ -n "$TARGET" ]]; then
                echo "error: unexpected argument: $1" >&2; exit 1
            fi
            TARGET="$1"; shift ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo "error: <target-dir> is required" >&2
    usage >&2
    exit 1
fi

# --- validate numeric inputs ------------------------------------------------

is_uint() { [[ "$1" =~ ^[0-9]+$ ]]; }

if [[ -n "$SIZE" ]]; then
    if [[ ! "$SIZE" =~ ^[0-9]+[KMGkmg]?$ ]]; then
        echo "error: --size must be a number with an optional K, M, or G suffix: $SIZE" >&2
        exit 1
    fi
    num="${SIZE%[KMGkmg]}"
    case "$SIZE" in
        *[Kk]) TARGET_BYTES=$(( num * 1024 )) ;;
        *[Mm]) TARGET_BYTES=$(( num * 1024 * 1024 )) ;;
        *[Gg]) TARGET_BYTES=$(( num * 1024 * 1024 * 1024 )) ;;
        *)     TARGET_BYTES=$num ;;
    esac
    if [[ "$TARGET_BYTES" -eq 0 ]]; then
        echo "error: --size must be greater than zero" >&2
        exit 1
    fi
else
    if ! is_uint "$ROWS" || [[ "$ROWS" -eq 0 ]]; then
        echo "error: --rows must be a positive integer: $ROWS" >&2
        exit 1
    fi
fi

if ! is_uint "$MALFORMED"; then
    echo "error: --malformed must be a non-negative integer: $MALFORMED" >&2
    exit 1
fi

if [[ ! -f "$SDAIS_ROOT/install.sh" ]]; then
    echo "error: install.sh not found at $SDAIS_ROOT — run this script from its place in the repo" >&2
    exit 1
fi

# --- prepare the target directory -------------------------------------------

if [[ -e "$TARGET" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
        echo "error: $TARGET already exists (use --force to replace it)" >&2
        exit 1
    fi
    if [[ ! -d "$TARGET" ]]; then
        echo "error: $TARGET exists and is not a directory; refusing to replace it" >&2
        exit 1
    fi
    if [[ ! -f "$TARGET/AGENTS.md" ]]; then
        echo "error: $TARGET does not look like a bootstrapped fixture (no AGENTS.md)." >&2
        echo "       Refusing to delete it. Remove it yourself if that is what you want." >&2
        exit 1
    fi
    echo "Replacing existing fixture at $TARGET"
    rm -rf "$TARGET"
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
PROJECT="$(basename "$TARGET")"

# --- scaffold ---------------------------------------------------------------

echo "Scaffolding SDAIS project '$PROJECT' in $TARGET"
( cd "$TARGET" && "$SDAIS_ROOT/install.sh" "$PROJECT" >/dev/null )

cp "$SCRIPT_DIR/sdais/gspec/v1/idea.md" "$TARGET/sdais/gspec/v1/idea.md"

# --- generate the CSV -------------------------------------------------------

mkdir -p "$TARGET/data"
CSV="$TARGET/data/records.csv"

if [[ -n "$SIZE" ]]; then
    echo "Generating $CSV (~$SIZE, $MALFORMED malformed)"
else
    echo "Generating $CSV ($ROWS rows, $MALFORMED malformed)"
fi

awk -v mode="${SIZE:+size}" \
    -v rows="${ROWS:-0}" \
    -v target_bytes="${TARGET_BYTES:-0}" \
    -v malformed="$MALFORMED" \
    'BEGIN {
        srand(42)
        if (mode == "") mode = "rows"

        split("ada,grace,alan,edsger,barbara,donald,ken,dennis,linus,margaret", first, ",")
        split("lovelace,hopper,turing,dijkstra,liskov,knuth,thompson,ritchie,torvalds,hamilton", last, ",")

        header = "id,name,email,amount,created_at"
        print header
        bytes = length(header) + 1

        # Spread malformed rows evenly by progress through the file rather than
        # by row index: in size mode the final row count is not known up front,
        # and estimating it from an assumed row width loses the last injections
        # whenever the estimate overshoots.
        injected = 0

        i = 0
        while (1) {
            if (mode == "rows" && i >= rows) break
            if (mode == "size" && bytes >= target_bytes) break
            i++

            fi = int(rand() * 10) + 1
            li = int(rand() * 10) + 1
            name = first[fi] " " last[li]
            email = first[fi] "." last[li] i "@example.com"
            amount = sprintf("%.2f", rand() * 1000)
            created = sprintf("2026-%02d-%02dT%02d:%02d:00Z",
                              int(rand() * 12) + 1, int(rand() * 28) + 1,
                              int(rand() * 24), int(rand() * 60))

            progress = (mode == "rows") ? i / rows : bytes / target_bytes
            if (injected < malformed && progress >= (injected + 1) / (malformed + 1)) {
                injected++
                k = injected % 3
                if (k == 1)      line = i "," name           # too few fields
                else if (k == 2) line = i "," name "," email "," amount "," created ",extra"
                else             line = i ",\"" name "," email "," amount "," created
            } else {
                line = i "," name "," email "," amount "," created
            }

            print line
            bytes += length(line) + 1
        }
    }' > "$CSV"

DATA_ROWS=$(( $(wc -l < "$CSV" | tr -d " ") - 1 ))
CSV_BYTES=$(wc -c < "$CSV" | tr -d " ")

# --- report -----------------------------------------------------------------

cat <<EOF

Done.
  project:  $TARGET
  prose:    sdais/gspec/v1/idea.md
  data:     data/records.csv ($DATA_ROWS data rows + 1 header, $CSV_BYTES bytes)

The fixture's E- item names SDAIS_DEMO_INPUT, so the Grounder has something
real to confirm:

  cd $TARGET
  export SDAIS_DEMO_INPUT="$TARGET/data"
  sdais claude <model> RequirementsEngineer

A correct first run lands in Mode A and writes sdais/gspec/v2/ with open
questions. Answer them there, re-run, and the second pass should reach Mode B
and write sdais/rsf/v1/. See README.md for what to check on each pass.
EOF
