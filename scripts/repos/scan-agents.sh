#!/bin/bash
set -euo pipefail

# Discover agents across all registered repos and build unified registry
# Usage: scan-agents.sh [--output registry.json]

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/../.." && pwd)")"
DEP_MAP="${ROOT_DIR}/.claude/dependency-map.json"
OUTPUT="${ROOT_DIR}/agents/registry.json"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output) OUTPUT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

echo "=== Agent Registry Scan ==="

if [[ ! -f "$DEP_MAP" ]]; then
    echo "No dependency map found. Register repos first."
    exit 1
fi

# Start building registry
REGISTRY='{"scan_timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'", "agents": []}'

scan_repo() {
    local repo_name="$1"
    local repo_path="$2"

    if [[ ! -d "${repo_path}/agents" ]]; then
        return
    fi

    for agent_file in "${repo_path}/agents/"*.md; do
        [[ -f "$agent_file" ]] || continue
        local basename
        basename=$(basename "$agent_file" .md)

        # Skip non-role files
        [[ "$basename" == "README" ]] && continue
        [[ "$basename" == "AGENT_INSTRUCTIONS" ]] && continue

        # Extract mission line
        local mission=""
        mission=$(grep -m1 "^## Mission" -A2 "$agent_file" 2>/dev/null | tail -1 | sed 's/^ *//' || echo "")

        # Check for required sections
        local sections=0
        for section in "## Mission" "## Use This Role When" "## Inputs Required" "## Outputs" "## Workflow" "## Guardrails"; do
            if grep -q "^${section}" "$agent_file" 2>/dev/null; then
                ((sections++))
            fi
        done
        local valid=$( [[ $sections -eq 6 ]] && echo "true" || echo "false" )

        REGISTRY=$(echo "$REGISTRY" | jq \
            --arg name "$basename" \
            --arg repo "$repo_name" \
            --arg path "$agent_file" \
            --arg mission "$mission" \
            --argjson valid "$valid" \
            '.agents += [{"name": $name, "repo": $repo, "path": $path, "mission": $mission, "schema_valid": $valid}]')
    done
}

# Scan root repo agents
scan_repo "$(basename "$ROOT_DIR")" "$ROOT_DIR"

# Scan registered child repos
jq -r '.repos | to_entries[] | "\(.key)|\(.value.path)"' "$DEP_MAP" 2>/dev/null | while IFS='|' read -r name path; do
    if [[ -d "$path" ]]; then
        scan_repo "$name" "$path"
    fi
done

# Write registry
echo "$REGISTRY" | jq '.' > "$OUTPUT"

# Summary
TOTAL=$(echo "$REGISTRY" | jq '.agents | length')
VALID=$(echo "$REGISTRY" | jq '[.agents[] | select(.schema_valid == true)] | length')
echo ""
echo "Found ${TOTAL} agent(s) across repos (${VALID} schema-valid)"
echo "Registry written to: ${OUTPUT}"

# List agents
echo ""
echo "$REGISTRY" | jq -r '.agents[] | "  \(.repo)/\(.name) \(if .schema_valid then "✓" else "✗" end) \(.mission)"'
