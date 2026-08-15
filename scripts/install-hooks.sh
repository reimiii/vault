#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$VAULT_DIR/.git/hooks/pre-commit"

cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
exec "$(git rev-parse --show-toplevel)/scripts/guard.sh"
EOF
chmod +x "$HOOK"

echo "pre-commit hook installed."
