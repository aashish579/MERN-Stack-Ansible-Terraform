# Validation status (before first AWS deployment)

The starter kit was authored against the three-page 2026 Hero Vired assignment brief and the public upstream TravelMemory README. The assignment is **not yet deployed to the learner's AWS account**.

## Completed offline checks

- All Ansible YAML files successfully parsed as YAML.
- All Ansible `.j2` templates parsed by the Jinja2 templating engine.
- Python helper scripts passed AST syntax parsing, and Bash helper scripts passed `bash -n`.
- `generate_inventory.py` was exercised against mocked Terraform outputs and produced both public web/private DB aliases, SSH ProxyCommand and Ansible inventory entries.
- `test_app.py` passed against a local mock HTTP service for home, health, GET trips, POST trip, GET trip by id and list persistence checks (this is **not** a real upstream app test).
- README contains 20 explicit Markdown embeds for actual screenshot paths, with no fake screenshot files.
- Git ignore rules exclude generated inventory, Vault passwords, AWS private keys, Terraform state and tfvars.

## Still required on the learner's Ubuntu / Hero Vired AWS account

- `terraform init`, `fmt`, `fmt -check`, `validate`, `plan`, `apply` (provider download/validation and AWS provisioning cannot be performed in the offline authoring environment).
- `ansible-galaxy collection install`, Ansible live syntax-check/connectivity, `ansible site.yml` execution and MongoDB user bootstrap on actual EC2.
- Real npm package installation and React production build from the current upstream TravelMemory repository.
- Full HTTP API POST/read/list test against deployed application and MongoDB authorized/unauthorized queries.
- Real AWS screenshots, a completed report, GitHub commit and Vlearn submission.

Do not describe these pending tasks as successful until you have actual command output. Correct any observed incompatibilities with the current upstream repository, record what changed and rerun the tests.
