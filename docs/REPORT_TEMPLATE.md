# Graded Project Report — Terraform + Ansible Deployment of MERN TravelMemory

> **Fill only after actual AWS deployment. Replace every `[ ... ]` placeholder and remove statements unsupported by your evidence.** Export this Markdown to PDF/Word for your evaluation if desired; README and original source must remain in GitHub.

**Learner:** [Your name]  
**Course:** [Hero Vired Multi-Cloud Architecture & DevOps]  
**Date:** [Date of actual completed deployment]  
**GitHub repository:** [Actual new repo URL]  
**AWS region:** [us-east-1 or the actual resource region]  
**Control node:** [Ubuntu 24.04.4 LTS on Windows 11 WSL2]

## 1. Objective

Automate provisioning of AWS VPC infrastructure with Terraform and configuration of two EC2 hosts with Ansible to deploy the MERN TravelMemory application. Demonstrate secure frontend/API/database connectivity, private database placement, IAM permissions, repeatable deployment and evidence of functional persistence.

## 2. Architecture and justification

Use the Mermaid diagram in README and explain:
- One VPC, separate public and private subnets with CIDRs.
- Internet Gateway route for public subnet and NAT Gateway egress route for private subnet.
- EC2 web (Nginx, React, Express) public IPv4 and EC2 MongoDB without public IPv4.
- SSH restricted to one learner public IP, database only from the web EC2 security group.
- Application ports: HTTP 80, Node/Express localhost 3001 via Nginx, MongoDB private 27017.
- IAM instance profiles with SSM policy and role trust to EC2.

## 3. Terraform implementation

**Files:** `versions.tf`, `providers.tf`, `variables.tf`, `network.tf`, `security.tf`, `iam.tf`, `compute.tf`, `outputs.tf`.

| AWS resource | Actual value / ID |
|---|---|
| VPC | [vpc ID and CIDR] |
| Public subnet | [subnet ID and CIDR] |
| Private subnet | [subnet ID and CIDR] |
| Internet Gateway | [IGW ID] |
| NAT Gateway | [NAT ID and status] |
| Public web EC2 | [instance ID / IP] |
| Private MongoDB EC2 | [instance ID / private IP] |
| IAM roles/profiles | [names] |

**Execution outcome:** `[terraform init/fmt/validate/plan/apply real results]`.

**Evidence:** `04_terraform_init_validate.png`, `05_terraform_apply_outputs.png`, `06_vpc_subnets.png`, `07_internet_gateway.png`, `08_nat_gateway.png`, `09_route_tables.png`, `10_ec2_instances.png`, `13_security_iam.png`.

## 4. Ansible implementation

Explain inventory generation, ProxyCommand/SSH through web instance, role/task order, MongoDB repository installation, admin and least-privileged app user creation, Vault secrets, Node.js installation, Git source cloning, `npm install`/`npm ci`, React build, Nginx API reverse proxy, backend systemd service and UFW/SSH hardening.

**Actual deployment recap:** [number of hosts, ok/changed/unreachable/failed].  
**Actual second-run recap:** [results, note drift or changes if present].  
**Evidence:** `11_ssh_proxy.png`, `12_ansible_ping.png`, `14_mongodb_configured.png`, `15_ansible_recap.png`.

## 5. Security design

- Web SSH source: [learner current public IPv4 /32].
- Database inbound: SSH 22 and MongoDB 27017 restricted to web security group; no public IPv4.
- MongoDB authorization enabled; dedicated `readWrite` app user for the `travelmemory` database; separate administrator.
- SSH keys kept locally; Ansible Vault encryption used; SSH password and root login disabled; UFW enabled.
- Both EC2 roles have SSM managed-instance policy; IMDSv2 enforced and volumes encrypted.
- Non-root backend process; Nginx is the only public application port.
- **Lab limits:** no HTTPS or app login is implemented (not production-grade).

## 6. Testing and results

| Test case | Command/action | Expected | Actual result | Evidence |
|---|---|---|---|---|
| AWS auth | `aws sts get-caller-identity` | SSO role | [actual] | 03 |
| Terraform validate | `terraform validate` | Successful | [actual] | 04 |
| Web SSH | `ssh -F ... travelmemory-web hostname` | Hostname | [actual] | 11 |
| DB SSH | `ssh -F ... travelmemory-db hostname` | Private host via web | [actual] | 11 |
| Ansible ping | `ansible all -m ping` | 2 SUCCESS | [actual] | 12 |
| MongoDB active | `systemctl is-active mongod` | active | [actual] | 14 |
| App homepage | Browser `http://WEB_IP/` | React loads | [actual] | 16 |
| API health | `GET /health` | 200 | [actual] | 18 |
| Insert a travel record | `POST /trip` | 201 | [actual] | 17–18 |
| Retrieve saved record | `GET /trip/:id` and `GET /trip` | 200 and same ID | [actual] | 18 |
| DB persistence | Verified DB count | >0 after test | [actual] | 19 |
| Unauthorized query | Mongosh without credentials | Rejected | [actual] | 19 |
| IaC repeatability | `terraform plan` and second Ansible run | No drift / no errors | [actual] | supplementary |

## 7. Problems encountered and resolution

[Record real incidents, exact causes, commands and outcomes. Examples may include WSL repository connectivity, AWS credential profile selection, IAM access, NAT routing or Node package issues, but do not invent incidents.]

## 8. Outcome and learning

[Explain what you personally verified about Terraform resources, private/public networking, Ansible idempotency, service management, MongoDB auth, and the MERN data flow.]

## 9. Submission details

**Repository:** [actual GitHub repository link]  
**Demonstration URL:** [live IP only while resources remain running; may expire after cleanup]  
**Evidence gallery:** [GitHub README renders screenshots 01–20]  
**Status:** [completed/not completed]  
**Cleanup status:** [resources running for review / destroyed after evaluation]
