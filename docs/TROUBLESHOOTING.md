# Troubleshooting — only apply the fix matching your error

### `AccessDenied` / still using old IAM identity (`github-actions-flask-cicd`)
Run `export AWS_PROFILE=hero-vired` and `aws sts get-caller-identity`. For expired Hero Vired SSO credentials use `aws sso login --profile hero-vired --use-device-code`. SSO region is `ap-south-1`; EC2 resource region in the kit is `us-east-1`. Do NOT overwrite the existing default AWS CLI credentials.

### `curl` or `apt` repository timeout in WSL / servers
Check `curl -4 -I https://archive.ubuntu.com/ubuntu/` in WSL; retry on a working network. On the database EC2, confirm private route table default points to an **Available** NAT Gateway and the NAT Gateway lives in the public subnet. If Ubuntu APT IPv6 is broken, use `sudo apt-get -o Acquire::ForceIPv4=true update` for diagnosis. Do not disable network firewalls to make commands appear to work.

### Terraform says `No valid credential sources found`
Run `export AWS_PROFILE=hero-vired && aws sts get-caller-identity`; verify your SSO login is active. `terraform -chdir=terraform init` also needs access to provider registry; check WSL internet connectivity.

### Terraform `InsufficientInstanceCapacity` / unsupported instance
Try another allowed type in `terraform/terraform.tfvars`, e.g. `t3.large` for web or `t3.medium` for DB, or change AWS resource region consistently, after checking AMI/quotas. The defaults are web `t3.medium`, DB `t3.small`, x86-64 Ubuntu 24.04.

### Terraform key pair error / cannot connect SSH
`bash scripts/prepare.sh` creates `~/.ssh/mern_hero_vired` and `.pub`. If your public internet IP changed, rerun `prepare.sh` then `terraform -chdir=terraform apply`, and regenerate inventory. **If UFW on the web EC2 still allows only your old IP, use the configured AWS Systems Manager access to update UFW from inside the instance** (if SSM agent is running) or restore access using a controlled recovery process. Never set SSH security group to `0.0.0.0/0` as a permanent fix.

### SSH warning `Permission denied (publickey)`
Confirm correct private key path `~/.ssh/mern_hero_vired`, ownership and permissions `chmod 600 ~/.ssh/mern_hero_vired`; ensure SSH to public web host works first, then database. Check the AWS key pair assigned to both EC2. Do not copy private SSH keys to GitHub or the web EC2.

### Ansible cannot connect to database
Check `ssh -F generated/ssh_config travelmemory-db hostname`. A generated SSH ProxyCommand tunnels via the public web host; the DB is *not* reachable directly. Confirm DB SG SSH 22 allows inbound from web SG, database private IP is correct, and the public host SSH forwarding remains enabled.

### `community.general.ufw` module not found
Run `ansible-galaxy collection install -r ansible/requirements.yml`. Ensure Ansible core 2.16.3 can see the installed collection.

### `mongodb-org` installation fails
The official MongoDB 8.0 repo is configured for **Ubuntu 24.04 noble**. Confirm AMI details and network/NAT. See MongoDB's official docs: https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/. Inspect `sudo apt update` error from DB via Ansible.

### `MongoDB Authentication failed`
Never regenerate `generated/secrets.yml` for an existing initialized database. Keep `generated/.vault_pass` and encrypted values together. Confirm `sudo systemctl status mongod` via the DB proxy host. If the database was configured with different passwords manually, debug securely instead of deleting data.

### Node dependency failure during `npm ci` or React build
Read actual npm error. A real upstream dependency conflict may require `npm install --legacy-peer-deps`, but document such a change in Ansible before doing it. The code expects backend `index.js`, port 3001 and frontend `REACT_APP_BACKEND_URL`. Inspect `sudo journalctl -u travelmemory --no-pager -n 50` and `sudo nginx -t` on the web host. You may need to re-run Ansible if upstream code changes.

### `/health` returns 502 / 503
502: Nginx cannot reach Node backend. Check `sudo systemctl status travelmemory` and `sudo journalctl -u travelmemory -n 80 --no-pager`. 503: backend cannot reach MongoDB; check DB `mongod`, private SG port 27017, the `/etc/travelmemory/backend.env` connection string **privately, without printing or copying it into the report**, and the MongoDB database user. Test `curl -i http://127.0.0.1:3001/health` locally on web.

### React works but API calls fail in browser
Open DevTools → Network. The frontend is built using `REACT_APP_BACKEND_URL=http://WEB_PUBLIC_IP`. After changing web EC2 public IP (for example, EC2 stop/start), regenerate inventory and rerun Ansible so frontend `.env.production` and backend CORS origin are rebuilt with the current IP. Do not expose 3001 directly to the internet; requests should use Nginx `/trip` and `/health` on port 80.

### API create test fails HTTP 400
Read the returned validation message. If upstream TravelMemory has changed field requirements, update the sample `scripts/test_app.py` to match the current upstream README and document the adjustment. Do not claim API test passed when it failed.

### Browser displays a blank page
Check browser console for build-time API URL or JS errors, verify `frontend/build/index.html`, and confirm Nginx serves the React build. Re-run Ansible with legitimate fixes; do not manually edit the app without documenting changes.

### GitHub images broken
Put your actual `.png` evidence under `evidence/screenshots/` with exact names specified in docs/SCREENSHOT_CHECKLIST.md, `git add`, commit, push and reload GitHub README. A Markdown link is not evidence unless the image exists and renders.

### Protecting AWS cost and accidental resource deletion
NAT Gateway/EIP, EC2 and gp3 storage incur charges. Do not use `terraform destroy` before recording your proof and completing any evaluator live review. `scripts/cleanup.sh` asks for explicit destruction confirmation.
