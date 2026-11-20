# Windows 11 → Ubuntu WSL: how to open the ZIP

You already created `/home/gautam/mern-terraform-ansible` in WSL. The ZIP download will normally be stored in Windows Downloads.

## Simple method (recommended)

1. Download `MERN_Terraform_Ansible_Assignment_Kit.zip` from this ChatGPT conversation in Windows.
2. Open **Ubuntu WSL** and run:
   ```bash
   cd ~/mern-terraform-ansible
   explorer.exe .
   ```
3. Windows File Explorer opens your current Ubuntu project folder. **Copy** the downloaded ZIP from Windows Downloads into this folder (do not drag-and-move if you want to keep the Windows backup).
4. Return to Ubuntu and run:
   ```bash
   cd ~/mern-terraform-ansible
   ls -lh MERN_Terraform_Ansible_Assignment_Kit.zip
   unzip -o MERN_Terraform_Ansible_Assignment_Kit.zip
   cd MERN_Terraform_Ansible_Kit
   pwd
   ls -la
   ```
5. Expected project path: `/home/gautam/mern-terraform-ansible/MERN_Terraform_Ansible_Kit`.

## Alternative: direct copy from Windows Downloads

If `explorer.exe .` does not open, use WSL's `/mnt/c` mount. Replace `WINDOWS_LOGIN_NAME` with your *Windows* username (may be different from Ubuntu user `gautam`):

```bash
cd ~/mern-terraform-ansible
ls /mnt/c/Users/
cp '/mnt/c/Users/WINDOWS_LOGIN_NAME/Downloads/MERN_Terraform_Ansible_Assignment_Kit.zip' .
unzip -o MERN_Terraform_Ansible_Assignment_Kit.zip
cd MERN_Terraform_Ansible_Kit
```

**Why work under `/home/gautam` rather than `/mnt/c/Windows/system32`?** Linux file permissions on SSH private keys and Ansible Vault work better in the native WSL filesystem.

## First execution after extracting

```bash
export AWS_PROFILE=hero-vired
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
aws sts get-caller-identity
bash scripts/prepare.sh
terraform -chdir=terraform init
terraform -chdir=terraform fmt
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
```

Stop and share any error, especially before `terraform apply`. Do not send AWS credentials or the contents of `generated/`.
