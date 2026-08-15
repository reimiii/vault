#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$VAULT_DIR"

"$VAULT_DIR/scripts/encrypt.sh"
"$VAULT_DIR/scripts/guard.sh"

git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git commit -m "vault: backup $(date -Iseconds)"
git push

echo "Backed up."
