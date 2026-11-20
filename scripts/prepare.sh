#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export AWS_PROFILE="${AWS_PROFILE:-hero-vired}"
export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"

cd "$ROOT"
echo "[1/4] Verifying AWS login as profile: $AWS_PROFILE"
if ! aws sts get-caller-identity --query Arn --output text; then
  echo "ERROR: AWS SSO session expired or profile is missing. Run: aws sso login --profile $AWS_PROFILE --use-device-code" >&2
  exit 1
fi

mkdir -p "$HOME/.ssh" "$ROOT/generated" "$ROOT/evidence/screenshots" "$ROOT/evidence/logs"
chmod 700 "$HOME/.ssh" "$ROOT/generated"
KEY="$HOME/.ssh/mern_hero_vired"
if [[ ! -f "$KEY" ]]; then
  echo "[2/4] Creating a new Ed25519 key pair for the project (no private key will be uploaded)"
  ssh-keygen -q -t ed25519 -f "$KEY" -N "" -C "hero-vired-terraform-ansible"
else
  echo "[2/4] Reusing your existing project SSH key"
fi
if [[ ! -f "$KEY.pub" ]]; then
  echo "ERROR: Found a private key but no corresponding public key: $KEY.pub" >&2
  exit 1
fi
chmod 600 "$KEY"
chmod 644 "$KEY.pub"

MY_IP="$(curl --ipv4 --fail --silent --show-error --connect-timeout 8 --max-time 15 https://checkip.amazonaws.com/ | tr -d '\r\n' || true)"
if ! python3 - "$MY_IP" <<'PY'
import ipaddress,sys
try: ipaddress.IPv4Address(sys.argv[1])
except ValueError: sys.exit(1)
PY
then
  echo "Cannot determine your public IPv4 automatically. Check https://checkip.amazonaws.com/ in a browser."
  read -r -p "Type YOUR public IPv4 address (not a private 192.168.* address): " MY_IP
fi
python3 - "$MY_IP" <<'PY'
import ipaddress,sys
ip=ipaddress.IPv4Address(sys.argv[1]); assert ip.is_global, 'Enter a public routable IPv4 address'
PY

echo "[3/4] Generating local Terraform variables: allowed SSH source $MY_IP/32"
cat > "$ROOT/terraform/terraform.tfvars" <<VARS
aws_region          = "$AWS_REGION"
project_name        = "travelmemory-lab"
allowed_ssh_cidr    = "$MY_IP/32"
ssh_public_key_path = "$KEY.pub"
web_instance_type   = "t3.medium"
db_instance_type    = "t3.small"
VARS
chmod 600 "$ROOT/terraform/terraform.tfvars"

echo "[4/4] Ready: terraform/terraform.tfvars and $KEY.pub"
echo "Next commands: terraform -chdir=terraform init && terraform -chdir=terraform fmt && terraform -chdir=terraform validate"
