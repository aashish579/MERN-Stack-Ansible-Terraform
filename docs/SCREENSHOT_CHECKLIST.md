# 20 screenshot checkpoints for grading

**Capture REAL terminal/browser/AWS Console evidence. Never fabricate results.** Use Win+Shift+S, save PNG in `evidence/screenshots/` under the exact names below, then push them to GitHub so the README images render. Crop for clarity but retain commands, status or resource identifiers. Redact email/account IDs if preferred; ALWAYS hide keys/passwords/tokens. One screenshot per item is a baseline, not an official rubric limit; split unreadable views into extra screenshots and embed them.

| # | Exact filename | When and what to capture | Grader interpretation |
|---|---|---|---|
| 01 | `01_wsl_ubuntu.png` | `wsl --list --verbose` plus `lsb_release -a` | Windows/WSL/Linux environment |
| 02 | `02_tool_versions.png` | `terraform version`, `ansible --version`, `aws --version`, `git --version` | Tool readiness |
| 03 | `03_aws_sso.png` | `aws sts get-caller-identity` and `aws ec2 describe-vpcs` using `hero-vired` | Real AWS authentication + EC2 access |
| 04 | `04_terraform_init_validate.png` | `terraform init`, `fmt -check`, `validate` successfully | Infrastructure as Code validation |
| 05 | `05_terraform_apply_outputs.png` | `terraform apply` success and `terraform output` public web IPv4 | Created resources + required output |
| 06 | `06_vpc_subnets.png` | AWS VPC Console VPC and 2 subnets, CIDRs and public/private tag | Correct network segregation |
| 07 | `07_internet_gateway.png` | IGW attached to project VPC | Public routing |
| 08 | `08_nat_gateway.png` | NAT Gateway in public subnet, status Available | Private subnet outbound connectivity |
| 09 | `09_route_tables.png` | Public RT `0.0.0.0/0→igw` and private RT `0.0.0.0/0→nat` (capture both) | Routing |
| 10 | `10_ec2_instances.png` | EC2 2 running instances, public web IPv4, database *no public IPv4* | Public web/private MongoDB placement |
| 11 | `11_ssh_proxy.png` | `ssh -F generated/ssh_config travelmemory-web hostname` and `...travelmemory-db hostname` | SSH to both, db via bastion without private-key copy |
| 12 | `12_ansible_ping.png` | `ansible all -m ping` with `SUCCESS` for both | Ansible connectivity |
| 13 | `13_security_iam.png` | Web SSH /32 + HTTP, DB SSH/Mongo from web SG only, roles with SSM policy | Security groups + IAM |
| 14 | `14_mongodb_configured.png` | Private server `systemctl is-active mongod`, bind private address, UFW status — *never show passwords* | MongoDB and host hardening |
| 15 | `15_ansible_recap.png` | `ansible-playbook ansible/site.yml ...` PLAY RECAP, `failed=0` and `unreachable=0` | Deployment completed |
| 16 | `16_homepage.png` | Windows browser TravelMemory homepage at `http://WEB_IP/` | Public frontend working |
| 17 | `17_create_trip.png` | Completed React trip form / new saved memory | User-facing create functionality |
| 18 | `18_api_persistence.png` | `python3 scripts/test_app.py --url http://WEB_IP` shows PASS create, fetch, list | Real API + DB persistence |
| 19 | `19_db_auth_records.png` | `ansible-playbook ansible/verify.yml ...` prints authorized MongoDB count + unauthorized rejection | DB read/write and access control |
| 20 | `20_github_repository.png` | Your GitHub repo with Terraform, Ansible, README and images visibly embedded | Complete reproducible submission |

**Additional evidence recommended:** `systemctl status travelmemory`, `curl -I http://WEB_IP`, `sudo ufw status verbose` on each instance, screenshots of IAM instance profiles, another Terraform `plan` with no changes, second Ansible run, and a read-after-browser-refresh. Add supplementary screenshots to the README with links and explanations if they materially improve your submission.

## How to include real screenshots in README

The README already embeds images like this:

```markdown
![Ansible deployed successfully](evidence/screenshots/15_ansible_recap.png)
```

Simply put the real PNG under that exact path. **Before final submission, open the GitHub README and verify that all the images actually display.** Do not submit empty/placeholder screenshots or expose IAM/SSO secrets.
