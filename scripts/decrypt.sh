#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$VAULT_DIR"

TARGETS=( ".ssh/id_ed25519" "gpg/key.asc" )

for f in "${TARGETS[@]}"; do
  if head -c 20 "$f" | grep -qF '$ANSIBLE_VAULT'; then
    ansible-vault decrypt "$f"
  fi
done
