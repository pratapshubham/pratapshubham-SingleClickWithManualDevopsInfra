
# 🚀 Devops Single-Click Deployment

This repository provides modular, production-ready Terraform code and environment overlays to provision Azure infrastructure with minimal manual steps. It is designed for teams wanting consistent, auditable, and repeatable provisioning via CI/CD.

**Project Overview**

- 🎯 Purpose: Offer a collection of focused Terraform modules and environment configurations that enable single-click provisioning of Azure resources (VNets, subnets, NSGs, NICs, VMs, Public IPs, Storage, etc.).
- 🎯 Goals:
  - Encapsulate Azure best practices and naming/tagging conventions.
  - Provide environment isolation (dev/preprod/prod) and remote state guidance.
  - Integrate with Azure DevOps pipeline for automated plan/apply flows.

**Repository Layout**

- 📁 `modules/` — reusable Terraform modules. Each module has inputs (`variables.tf`) and outputs (`outputs.tf`) and focuses on a single Azure concept.
- 📁 `environment/` — environment overlays (per-environment `main.tf`, `provider.tf`, `terraform.tfvars`, and local `terraform.tfstate` if present).
- ⚙️ `azure-pipelines.yml` — CI pipeline to run Terraform `plan`/`apply`.

Example tree:

```
azure-pipelines.yml
README.md
environment/
  preprod/
    main.tf
    provider.tf
    terraform.tfvars
    variable.tf
modules/
  azure_virtual_network/
    main.tf
    variable.tf
    outputs.tf
  azure_subnet/
  azure_nic/
  azure_network_security_group/
  azure_nsg_association/
  azure_public_ip/
  azure_resources_group/
  azure_storage_account/
  azure_virtual_machine/
  azure_bastion_subnet/
```

**Prerequisites**

- 🔧 Tools:
  - Terraform >= 1.0 (recommend stable latest 1.x release). Use a `.terraform-version` or `required_version` in your root `versions.tf` to enforce.
  - Azure CLI (`az`) for authentication.
  - (Optional) `tflint`, `tfsec`, `checkov` for linting/security scanning; `terratest` for integration tests.
- 🔐 Permissions: An Azure subscription and the ability to create Resource Groups, Storage Accounts (for state), and Service Principals for CI.

**Quick Start (local)**

1. Authenticate and set subscription:

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

2. Example: deploy `preprod` overlay locally (sanity-run only):

```bash
cd environment/preprod
terraform init
terraform validate
terraform fmt -check
terraform plan -var-file=terraform.tfvars
# When ready
terraform apply -var-file=terraform.tfvars
```

3. Recommended workflow:
  - Keep sensitive values out of `terraform.tfvars`; prefer environment variables, pipeline secrets, or a Key Vault reference.
  - Run `terraform fmt` and `tflint` before committing.

**Example `terraform.tfvars` snippets & explanation**

- `resource_group_name`: Name of the RG to create/use.
- `location`: Azure region (e.g., `eastus`).
- `vnet_cidr`: VNet CIDR block (e.g., `10.0.0.0/16`).
- `subnet_cidrs`: Map/list of subnets and their CIDRs.

Example:

```hcl
resource_group_name = "rg-preprod-app"
location            = "eastus"
vnet_cidr           = "10.0.0.0/16"
subnet_cidrs = {
  app = "10.0.1.0/24"
  db  = "10.0.2.0/24"
}
vm_size = "Standard_DS2_v2"
```

**Environments & State (detailed)**

- Each environment has its own folder under `environment/` to keep configs isolated and allow different variable values per environment.
- For collaboration, use a remote backend. Example Azure Storage backend configuration (add to `provider.tf` or `backend.tf`):

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstate<unique>"
    container_name       = "tfstate"
    key                  = "environment/preprod/terraform.tfstate"
  }
}
```

- Create the backend storage account manually (or via a bootstrap script) and grant the pipeline/service principal access to it.
- Enable soft-delete and versioning on the storage account for state safety.

**Modules (detailed usage patterns)**

- Modules are intentionally small and composable. Typical usage:

```hcl
module "vnet" {
  source      = "../modules/azure_virtual_network"
  name        = "vnet-preprod"
  location    = var.location
  address_space = [var.vnet_cidr]
}

module "subnet_app" {
  source     = "../modules/azure_subnet"
  vnet_id    = module.vnet.id
  name       = "app"
  cidr_block = var.subnet_cidrs["app"]
}
```

- Check module `variable.tf` and `outputs.tf` to learn expected inputs/outputs. Keep modules stable: bump module outputs carefully (semver-like discipline).

**Naming, Tagging & Conventions**

- Use a clear naming convention: `<project>-<env>-<component>-<suffix>` (e.g., `app-preprod-vm-01`).
- Standard tags: `Environment`, `Owner`, `Project`, `CostCenter`.
- Reserve resource name length constraints (Azure limits for certain resources) — add truncation helpers if needed.

**CI/CD (Azure DevOps) — practical notes**

- The `azure-pipelines.yml` in the repo contains pipeline steps for `terraform init`, `plan`, and `apply`.
- Pipeline secrets:
  - Store the Service Principal credentials as secure pipeline variables or use an Azure DevOps service connection.
  - Store storage account keys in pipeline variables or let the SP access the storage account via RBAC.
- Typical pipeline flow:
  1. Checkout code
  2. Setup Terraform and Azure CLI
  3. Authenticate using Service Principal or Managed Identity
  4. `terraform init` (with backend configured)
  5. `terraform plan` (upload plan artifact)
  6. Manual approval gate for `terraform apply` in production

**Creating a Service Principal (example)**

```bash
az ad sp create-for-rbac --name "sp-terraform-prod" --role "Contributor" \
  --scopes "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-tfstate" \
  --sdk-auth
```

Save the JSON output securely and configure it in pipeline service connections.

**Security & Secrets (deep dive)**

- Never commit secrets. Patterns:
  - Use Azure Key Vault to store secrets and reference them in pipelines.
  - Use pipeline secure variables or variable groups with secrets.
- RBAC: Grant least-privilege roles to SPs (for example, `Storage Blob Data Contributor` on the tfstate container if you prefer scoped access).
- State protection: Enable soft-delete and point-in-time restore on storage accounts; use locks on critical resources.

**Testing, Linting & Scanning**

- Format: `terraform fmt -recursive`.
- Lint: `tflint` with Azure plugin.
- Security: `tfsec`, `checkov` to catch insecure defaults; run in CI.
- Integration tests: Use `terratest` (Go) or local `terraform apply` with destroyed cleanup in test harness.

**Troubleshooting & Debugging**

- Authentication errors: re-run `az login` and validate `az account show` output.
- Backend errors: check storage account keys, container existence, and RBAC permissions.
- Plan drift / state mismatch: run `terraform refresh` and inspect `terraform state list`.
- Resource limits: check Azure subscription quotas and VM SKU availability in the chosen region.

**Operational Recommendations**

- Tag resources for cost allocation and automation.
- Use Azure Monitor and Diagnostics to collect metrics and logs from VMs and PaaS resources.
- Implement lifecycle policies (e.g., prevent accidental deletion with `prevent_destroy` where appropriate, but apply judiciously).

**Contributing**

- Fork and open a PR with clear description, scope, and test steps.
- Run `terraform fmt`, `tflint`, and unit/integration tests before opening PRs.

**License**

- Add your license of choice (MIT, Apache-2.0, etc.) at the repo root.

**Contact / Support**

- For repo-specific questions, open an issue describing environment, commands run, and failure logs.
**Bastion Module (modules/azure_bastion_subnet) 🔐**

- Purpose: Provide a simple, repeatable way to create Azure Bastion Hosts by referencing existing subnets and public IPs. The module uses data sources to look up resources and provisions one `azurerm_bastion_host` per map entry provided in the input.

- Key implementation notes:
  - The module expects a map-of-objects input (named `shubham_bastion`) where each entry describes one Bastion host to create.
  - It uses `data.azurerm_subnet` to resolve an existing subnet and `data.azurerm_public_ip` for an existing Public IP.
  - For each input key the module creates an `azurerm_bastion_host` with a single `ip_configuration` referencing the subnet and public IP.

- Required Azure constraints and best-practices:
  - Subnet name: Azure requires the dedicated subnet name `AzureBastionSubnet` for Bastion. Always use this name or ensure the name you pass is the official bastion subnet.
  - Subnet size: Minimum recommended prefix `/26` (or larger) to accommodate service requirements and future growth.
  - Public IP: Use a Standard SKU Public IP (static allocation recommended). The Public IP must be created beforehand if you are using the module's lookup behavior.
  - Dedicated subnet: Do not place other resources inside the Bastion subnet.

- Permissions:
  - The principal running Terraform needs read access to the existing Subnet and Public IP and create permissions for `Microsoft.Network/bastionHosts/*` in the RG.

- Expected input shape (recommended typed schema):

```hcl
variable "shubham_bastion" {
  type = map(object({
    name                 = string
    location             = string
    resource_group_name  = string
    virtual_network_name = string
    subnet_name          = string
    public_ip_name       = string
  }))
}
```

- Example usage:

```hcl
module "bastion" {
  source = "../modules/azure_bastion_subnet"
  shubham_bastion = {
    preprod-bastion = {
      name                = "bastion-preprod"
      location            = "eastus"
      resource_group_name = "rg-preprod-network"
      virtual_network_name= "vnet-preprod"
      subnet_name         = "AzureBastionSubnet"
      public_ip_name      = "pip-bastion-preprod"
    }
  }
}
```

- Suggested outputs to add (not currently present):

```hcl
output "bastion_ids" {
  value = { for k, v in azurerm_bastion_host.bastion : k => v.id }
}

output "bastion_names" {
  value = { for k, v in azurerm_bastion_host.bastion : k => v.name }
}
```

- Caveats & improvement suggestions:
  - Current module file (`modules/azure_bastion_subnet/main.tf`) treats `public_ip_name` as required; if an entry omits it or sends an empty string the plan will fail. Options:
    1. Document and enforce `public_ip_name` as required.
    2. Make `public_ip_name` optional and conditionally set `public_ip_address_id` only when provided.
    3. Provide an option for the module to create the Public IP when not provided (adds convenience but increases module scope).
  - Add a typed `variable "shubham_bastion"` with validation blocks to improve UX and catch misconfigurations early.
  - Add module-level tests (e.g., using `terratest`) and linting (`tflint`, `tfsec`) patterns in CI for this module.

- Reference implementation files:
  - [modules/azure_bastion_subnet/main.tf](modules/azure_bastion_subnet/main.tf#L1-L99)
  - [modules/azure_bastion_subnet/variable.tf](modules/azure_bastion_subnet/variable.tf#L1)




- Add a sample `backend.tf` bootstrap script to create the storage account and container.
- Expand `azure-pipelines.yml` with concrete variable templates and approval gates.

Azure 2-Tier Infrastructure using Terraform

This project demonstrates the deployment of a production-style 2-Tier Azure Infrastructure using Terraform with a modular and reusable architecture.

The infrastructure is built following Terraform best practices, making it scalable, maintainable, and easy to extend for multiple environments.

🚀 Features
Azure Resource Group
Virtual Network (VNet)
Frontend Subnet
Backend Subnet
Frontend Linux VM
Backend Linux VM
Public IP
Network Security Group (NSG)
NSG Association with Subnets
Modular Terraform Architecture
Reusable Child Modules
Variables & tfvars
Maps & Nested Maps
for_each
Data Sources
Dependency Management
Clean Project Structure
📂 Project Structure
modules/
├── azure_resource_group
├── azure_virtual_network
├── azure_subnet
├── azure_public_ip
├── azure_nic
├── azure_network_security_group
├── azure_nsg_association
└── azure_virtual_machine

environment/
└── preprod/
    ├── main.tf
    ├── provider.tf
    ├── variable.tf
    └── terraform.tfvars
🛠️ Technologies Used
Terraform
Microsoft Azure
Azure Virtual Machines
Azure Networking
Infrastructure as Code (IaC)
📌 Terraform Concepts Covered
Child Modules
Reusable Modules
Variables
Maps & Nested Maps
for_each
Data Sources
depends_on
Modular Design
Infrastructure as Code (IaC)
📈 Future Enhancements
Azure Load Balancer
Azure Application Gateway
Azure Bastion
Azure Key Vault
VM Scale Sets
Azure Monitor
Remote Backend
State Locking
GitHub Actions CI/CD
Azure DevOps Pipeline
