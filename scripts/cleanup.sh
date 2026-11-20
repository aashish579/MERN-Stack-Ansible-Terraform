#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export AWS_PROFILE="${AWS_PROFILE:-hero-vired}"
export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_DEFAULT_REGION="$AWS_REGION"
echo "WARNING: This will DESTROY the AWS EC2 instances, VPC, NAT Gateway, and stored database records."
echo "Do this only after capturing all grading evidence and confirming no live evaluation remains."
read -r -p "Type DESTROY-TRAVELMEMORY to continue: " answer
[[ "$answer" == "DESTROY-TRAVELMEMORY" ]] || { echo "Cancelled"; exit 1; }
aws sts get-caller-identity --query Arn --output text
terraform -chdir=terraform destroy
