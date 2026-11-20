#!/usr/bin/env bash
# Generates encrypted Ansible Vault values. Does not print or commit passwords.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
umask 077
mkdir -p generated
chmod 700 generated
if [[ -f generated/secrets.yml && -f generated/.vault_pass ]]; then
  if head -n 1 generated/secrets.yml | grep -q '^\$ANSIBLE_VAULT;'; then
    echo "Existing encrypted Vault credentials retained. Do not regenerate during a deployment."
    exit 0
  fi
  echo "ERROR: generated/secrets.yml exists but is not encrypted; inspect privately and correct it." >&2
  exit 1
fi
if [[ -e generated/secrets.yml || -e generated/.vault_pass ]]; then
  echo "ERROR: Partial Vault material exists. Do not overwrite; contact the guide/troubleshooting section." >&2
  exit 1
fi
TMP="$(mktemp "$ROOT/generated/.secrets-XXXXXXXX")"
trap 'rm -f "$TMP"' EXIT
python3 - "$TMP" "$ROOT/generated/.vault_pass" <<'PY'
import pathlib, secrets, string, sys
alphabet = string.ascii_letters + string.digits
passwd = lambda: ''.join(secrets.choice(alphabet) for _ in range(36))
pathlib.Path(sys.argv[1]).write_text("mongo_admin_password: '" + passwd() + "'\nmongo_app_password: '" + passwd() + "'\n")
pathlib.Path(sys.argv[2]).write_text(secrets.token_urlsafe(48) + "\n")
PY
ansible-vault encrypt --vault-password-file generated/.vault_pass --output generated/secrets.yml "$TMP"
chmod 600 generated/secrets.yml generated/.vault_pass
rm -f "$TMP"
trap - EXIT
echo "Encrypted generated/secrets.yml is ready; passwords were not printed."
echo "Both generated/secrets.yml and generated/.vault_pass are ignored by Git."
