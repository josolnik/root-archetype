#!/bin/bash
set -euo pipefail

# Root-Archetype Project Initializer
# Usage: ./init-project.sh <project-name> <project-root> [--repos "name:path,name:path"]

usage() {
    echo "Usage: $0 <project-name> <project-root> [--repos \"name:path,name:path\"] [--email \"user@example.com\"]"
    echo ""
    echo "  project-name   Short identifier (e.g., my-project)"
    echo "  project-root   Absolute path where the root repo will be created"
    echo "  --repos        Comma-separated child repos to register (name:path pairs)"
    echo "  --email        Maintainer email for the seeded project"
    echo ""
    echo "Example:"
    echo "  $0 my-project /tmp/test --repos \"app:/tmp/app,lib:/tmp/lib\" --email \"dev@example.com\""
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

PROJECT_NAME="$1"
PROJECT_ROOT="$2"
shift 2

REPOS=""
MAINTAINER_EMAIL=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repos)
            REPOS="$2"
            shift 2
            ;;
        --email)
            MAINTAINER_EMAIL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

ARCHETYPE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Root-Archetype Project Initializer ==="
echo "Project:  ${PROJECT_NAME}"
echo "Root:     ${PROJECT_ROOT}"
echo "Email:    ${MAINTAINER_EMAIL:-not set}"
echo "Repos:    ${REPOS:-none}"
echo ""

# --- Create project directory ---
if [[ -d "${PROJECT_ROOT}" ]]; then
    echo "WARNING: ${PROJECT_ROOT} already exists. Merging into existing directory."
else
    mkdir -p "${PROJECT_ROOT}"
fi

# --- Initialize git if needed ---
if [[ ! -d "${PROJECT_ROOT}/.git" ]]; then
    git init "${PROJECT_ROOT}"
    cd "${PROJECT_ROOT}"
    git checkout -b main 2>/dev/null || true
else
    cd "${PROJECT_ROOT}"
fi

# --- Copy archetype structure ---
echo "Copying archetype structure..."

# Directories
mkdir -p agents/shared agents/roles
mkdir -p scripts/{hooks,validate,session,utils,repos}
mkdir -p .claude/{commands,skills}
mkdir -p notes
mkdir -p docs/guides
mkdir -p .devcontainer
mkdir -p logs
mkdir -p knowledge/{wiki,research}
mkdir -p local
mkdir -p repos
mkdir -p secrets

# --- Template substitution function ---
substitute() {
    local file="$1"
    sed -i \
        -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{PROJECT_ROOT}}|${PROJECT_ROOT}|g" \
        -e "s|{{MAINTAINER_EMAIL}}|${MAINTAINER_EMAIL}|g" \
        "$file"
}

# --- Copy and substitute template files ---
copy_and_sub() {
    local src="$1"
    local dst="$2"
    if [[ -f "${ARCHETYPE_DIR}/${src}" ]]; then
        cp "${ARCHETYPE_DIR}/${src}" "${dst}"
        substitute "${dst}"
    fi
}

# Core governance files
copy_and_sub "CLAUDE.md" "CLAUDE.md"
copy_and_sub "README.md" "README.md"

# Agent system
for f in "${ARCHETYPE_DIR}"/agents/roles/*.md; do
    [[ -f "$f" ]] && cp "$f" "agents/roles/$(basename "$f")"
done
for f in "${ARCHETYPE_DIR}"/agents/*.md; do
    [[ -f "$f" ]] && cp "$f" "agents/$(basename "$f")"
done
for f in "${ARCHETYPE_DIR}"/agents/shared/*.md; do
    [[ -f "$f" ]] && cp "$f" "agents/shared/$(basename "$f")"
done

# Hooks (all copied, user enables via settings.json)
for f in "${ARCHETYPE_DIR}"/scripts/hooks/*.sh; do
    [[ -f "$f" ]] && cp "$f" "scripts/hooks/$(basename "$f")" && chmod +x "scripts/hooks/$(basename "$f")"
done

# Validators
for f in "${ARCHETYPE_DIR}"/scripts/validate/*; do
    [[ -f "$f" ]] && cp "$f" "scripts/validate/$(basename "$f")"
done
chmod +x scripts/validate/*.py 2>/dev/null || true

# Session management
for f in "${ARCHETYPE_DIR}"/scripts/session/*.sh; do
    [[ -f "$f" ]] && cp "$f" "scripts/session/$(basename "$f")" && chmod +x "scripts/session/$(basename "$f")"
done

# Utils
for f in "${ARCHETYPE_DIR}"/scripts/utils/*.sh; do
    [[ -f "$f" ]] && cp "$f" "scripts/utils/$(basename "$f")" && chmod +x "scripts/utils/$(basename "$f")"
done

# Repo management
for f in "${ARCHETYPE_DIR}"/scripts/repos/*.sh; do
    [[ -f "$f" ]] && cp "$f" "scripts/repos/$(basename "$f")" && chmod +x "scripts/repos/$(basename "$f")"
done

# Claude Code config
copy_and_sub ".claude/settings.json" ".claude/settings.json" 2>/dev/null || true
for f in "${ARCHETYPE_DIR}"/.claude/commands/*.md; do
    [[ -f "$f" ]] && cp "$f" ".claude/commands/$(basename "$f")"
done

# Skills (copy all surviving skills)
for skill_dir in "${ARCHETYPE_DIR}"/.claude/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    mkdir -p ".claude/skills/${skill_name}"
    for f in "${skill_dir}"*; do
        [[ -f "$f" ]] && cp "$f" ".claude/skills/${skill_name}/$(basename "$f")"
    done
    # Copy subdirectories (references/, scripts/, assets/)
    for subdir in references scripts assets; do
        if [[ -d "${skill_dir}${subdir}" ]]; then
            mkdir -p ".claude/skills/${skill_name}/${subdir}"
            for f in "${skill_dir}${subdir}/"*; do
                [[ -f "$f" ]] && cp "$f" ".claude/skills/${skill_name}/${subdir}/$(basename "$f")"
            done
        fi
    done
done

# Hook library and policy hooks
mkdir -p .claude/hooks/lib
for f in "${ARCHETYPE_DIR}"/.claude/hooks/*.sh; do
    [[ -f "$f" ]] && cp "$f" ".claude/hooks/$(basename "$f")" && chmod +x ".claude/hooks/$(basename "$f")"
done
for f in "${ARCHETYPE_DIR}"/.claude/hooks/lib/*; do
    [[ -f "$f" ]] && cp "$f" ".claude/hooks/lib/$(basename "$f")"
done

# Secrets protection
cp "${ARCHETYPE_DIR}/secrets/.secretpaths" "secrets/.secretpaths"
touch "secrets/.gitkeep"

# Gitkeep files
touch knowledge/wiki/.gitkeep knowledge/research/.gitkeep local/.gitkeep repos/.gitkeep

# Devcontainer
copy_and_sub ".devcontainer/devcontainer.json" ".devcontainer/devcontainer.json" 2>/dev/null || true

# Maintainers config (required by tamper-proofing hook)
if [[ -f "${ARCHETYPE_DIR}/.claude/maintainers.json" ]]; then
    cp "${ARCHETYPE_DIR}/.claude/maintainers.json" ".claude/maintainers.json"
    substitute ".claude/maintainers.json"
fi

# --- Build repo map rows for CLAUDE.md ---
REPO_MAP_ROWS=""
if [[ -n "$REPOS" ]]; then
    echo "Registering child repos..."
    IFS=',' read -ra REPO_PAIRS <<< "$REPOS"
    for pair in "${REPO_PAIRS[@]}"; do
        IFS=':' read -r name path <<< "$pair"
        name=$(echo "$name" | xargs)
        path=$(echo "$path" | xargs)
        REPO_MAP_ROWS="${REPO_MAP_ROWS}| ${name} | \`${path}\` | (configure purpose) |\n"
    done
    # Substitute repo map into CLAUDE.md
    sed -i "s|{{REPO_MAP_ROWS}}|${REPO_MAP_ROWS}|g" CLAUDE.md
else
    sed -i '/{{REPO_MAP_ROWS}}/d' CLAUDE.md
fi

# --- Register child repos ---
if [[ -n "$REPOS" ]]; then
    IFS=',' read -ra REPO_PAIRS <<< "$REPOS"
    for pair in "${REPO_PAIRS[@]}"; do
        IFS=':' read -r name path <<< "$pair"
        name=$(echo "$name" | xargs)
        path=$(echo "$path" | xargs)
        if [[ -x "scripts/repos/register-repo.sh" ]]; then
            bash scripts/repos/register-repo.sh "$name" "$path" || echo "WARNING: Could not register ${name}"
        fi
    done
fi

# --- Write archetype manifest ---
ARCHETYPE_VERSION=$(cd "${ARCHETYPE_DIR}" && git rev-parse HEAD 2>/dev/null || echo "unknown")
cat > .archetype-manifest.json << MANEOF
{
  "archetype_origin": "${ARCHETYPE_DIR}",
  "archetype_version": "${ARCHETYPE_VERSION}",
  "init_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "template_values": {
    "PROJECT_NAME": "${PROJECT_NAME}",
    "PROJECT_ROOT": "${PROJECT_ROOT}",
    "MAINTAINER_EMAIL": "${MAINTAINER_EMAIL}"
  },
  "portable_paths": [
    "scripts/hooks/",
    "scripts/validate/",
    "scripts/utils/",
    "scripts/session/",
    "scripts/repos/",
    "agents/shared/",
    "agents/roles/",
    "agents/*.md",
    ".claude/commands/",
    ".claude/skills/",
    "secrets/.secretpaths"
  ],
  "templated_files": [
    "CLAUDE.md",
    "README.md"
  ]
}
MANEOF

# --- Create .gitignore ---
copy_and_sub ".gitignore" ".gitignore" 2>/dev/null || true

# --- Post-init validation ---
echo ""
echo "Running post-init validation..."
VALIDATION_FAILED=0

# Check required structure
for d in agents agents/shared agents/roles scripts/hooks scripts/validate scripts/session scripts/utils \
         notes .claude/commands .claude/skills; do
    if [[ ! -d "$d" ]]; then
        echo "  WARN: Missing directory: $d"
        VALIDATION_FAILED=1
    fi
done

for f in CLAUDE.md .claude/settings.json .claude/maintainers.json .archetype-manifest.json; do
    if [[ ! -f "$f" ]]; then
        echo "  WARN: Missing file: $f"
        VALIDATION_FAILED=1
    fi
done

# Sandbox prerequisite check
if ! command -v bwrap &>/dev/null; then
    echo "  WARN: bubblewrap (bwrap) not installed. Sandbox will not work."
    echo "  Install: sudo apt install bubblewrap (Debian/Ubuntu)"
    echo "  Without sandbox, hooks cannot enforce OS-level read/write restrictions."
    VALIDATION_FAILED=1
fi

# Run validators if Python available
if command -v python3 &>/dev/null; then
    python3 scripts/validate/validate_agents_structure.py 2>/dev/null || VALIDATION_FAILED=1
    python3 scripts/validate/validate_agents_references.py 2>/dev/null || VALIDATION_FAILED=1
    python3 scripts/validate/validate_claude_md_consistency.py 2>/dev/null || VALIDATION_FAILED=1
    python3 scripts/validate/validate_document_drift.py 2>/dev/null || VALIDATION_FAILED=1
fi

if [[ $VALIDATION_FAILED -eq 0 ]]; then
    echo "Post-init validation passed"
else
    echo "Post-init validation completed with warnings (see above)"
fi

echo ""
echo "=== Project initialized: ${PROJECT_NAME} ==="
echo "Root: ${PROJECT_ROOT}"
echo ""
echo "Next steps:"
echo "  1. Review and customize CLAUDE.md"
echo "  2. Configure hooks in .claude/settings.json"
echo "  3. Add agent roles in agents/roles/"
echo "  4. Register child repos: scripts/repos/register-repo.sh <name> <path>"
echo "  5. Install bubblewrap for sandbox: sudo apt install bubblewrap"
echo "  6. Review secrets/.secretpaths and add project-specific protected paths"
