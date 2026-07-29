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
