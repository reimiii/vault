#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$VAULT_DIR"

SECRETS=( ".ssh/id_ed25519" "gpg/key.asc" )

fail=0
for f in "${SECRETS[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "!! missing: $f"
    fail=1
    continue
  fi
  if ! head -c 20 "$f" | grep -qF '$ANSIBLE_VAULT'; then
    echo "!! PLAINTEXT: $f"
    fail=1
  fi
done

if [[ $fail -ne 0 ]]; then
  echo "Danger: above secrets are NOT ansible-vault encrypted. Run scripts/encrypt.sh"
  exit 1
fi

echo "OK: all secrets are ansible-vault encrypted."
