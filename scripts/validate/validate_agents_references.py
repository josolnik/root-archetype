#!/usr/bin/env python3
"""Validate local markdown references in governance files."""

import re
import sys
from pathlib import Path

def find_references(content: str) -> list[str]:
    """Extract local file references from markdown."""
    refs = []
    # Backtick refs: `path/file.md`
    refs.extend(re.findall(r'`([^`]+\.(?:md|sh|py|json|yaml|yml))`', content))
    # Link refs: [text](path/file.md)
    refs.extend(re.findall(r'\[[^\]]*\]\(([^)]+\.(?:md|sh|py|json|yaml|yml))\)', content))
    return refs

def validate():
    repo_root = Path(__file__).resolve().parent.parent.parent
    scan_patterns = [
        "agents/README.md",
        "agents/AGENT_INSTRUCTIONS.md",
        "CLAUDE.md",
    ]

    broken = []
    for pattern in scan_patterns:
        f = repo_root / pattern
        if not f.exists():
            continue
        content = f.read_text()
        for ref in find_references(content):
            if ref.startswith("http://") or ref.startswith("https://"):
                continue
            # Try relative to file, then repo root
            resolved = f.parent / ref
            if not resolved.exists() and not (repo_root / ref).exists():
                broken.append((f.name, ref))

    if broken:
        print("Reference validation FAILED — broken references:")
        for source, ref in broken:
            print(f"  {source} → {ref}")
        return False
    else:
        print("Reference validation passed")
        return True

if __name__ == "__main__":
    sys.exit(0 if validate() else 1)
