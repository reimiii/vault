#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$VAULT_DIR"

TARGETS=( ".ssh/id_ed25519" "gpg/key.asc" )

for f in "${TARGETS[@]}"; do
  if ! head -c 20 "$f" 2>/dev/null | grep -qF '$ANSIBLE_VAULT'; then
    ansible-vault encrypt "$f"
  fi
done

exec "$VAULT_DIR/scripts/guard.sh"
