#!/bin/bash
set -euo pipefail

# Add a dependency edge between two registered repos
# Usage: add-dependency.sh <from-repo> <to-repo> <coupling-type> [--note "description"]

usage() {
    echo "Usage: $0 <from-repo> <to-repo> <coupling-type> [--note \"description\"]"
    echo ""
    echo "Coupling types: binary, data, validation, config, api"
    echo ""
    echo "Example:"
    echo "  $0 orchestrator llama binary --note \"Launches llama-server subprocess\""
    exit 1
}

if [[ $# -lt 3 ]]; then
    usage
fi

FROM="$1"
TO="$2"
COUPLING="$3"
shift 3

NOTE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --note) NOTE="$2"; shift 2 ;;
        *) echo "Unknown: $1"; usage ;;
    esac
done

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"
DEP_MAP="${ROOT_DIR}/.claude/dependency-map.json"

if [[ ! -f "$DEP_MAP" ]]; then
    echo "No dependency map found."
    exit 1
fi

# Add edge
TMP=$(mktemp)
jq --arg from "$FROM" --arg to "$TO" --arg coupling "$COUPLING" --arg note "$NOTE" \
    '.edges += [{"from": $from, "to": $to, "coupling": $coupling, "note": $note}]' \
    "$DEP_MAP" > "$TMP" && mv "$TMP" "$DEP_MAP"

echo "Added dependency: ${FROM} → ${TO} (${COUPLING})"
[[ -n "$NOTE" ]] && echo "  Note: ${NOTE}"
