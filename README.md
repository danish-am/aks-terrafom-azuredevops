# 🚀 AKS Provisioning with Terraform and Azure DevOps Pipelines

This repository demonstrates **end-to-end automation** for deploying an **Azure Kubernetes Service (AKS)** cluster using **Terraform**, integrated with **Azure DevOps Pipelines** for continuous infrastructure delivery.  

---

## 📖 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Setup Prerequisites](#setup-prerequisites)
- [Detailed Setup Instructions](#detailed-setup-instructions)
  - [Azure Key Vault Configuration](#1-azure-key-vault-configuration)
  - [Azure DevOps Service Connection Configuration](#2-azure-devops-service-connection-configuration)
  - [Azure DevOps Pipeline Overview](#3-azure-devops-pipeline-overview)
- [Terraform Backend Configuration](#terraform-backend-configuration)
- [Permissions Required](#permissions-required)
- [Running the Pipeline](#running-the-pipeline)
- [Best Practices and Notes](#best-practices-and-notes)
---

## 🧩 Overview

This project provisions the following infrastructure on Azure:

- An Azure Kubernetes Service (**AKS**) Cluster.
- Associated Azure resources like Virtual Network (VNet), Subnets, and Managed Identity (depending on Terraform modules).

The infrastructure deployment is automated through **Azure DevOps Pipelines**, ensuring Infrastructure as Code (IaC) best practices, secret management through **Azure Key Vault**, and reliable state management via **Terraform backend**.

---

---

## 📂 Repository Structure

> ✅ **All code and pipeline YAML definitions are located directly under the `main` branch.** 

Key files:
- `main.tf` — Main Terraform configuration.
- `variables.tf` — Input variables for the Terraform modules.
- `outputs.tf` — Terraform output definitions.
- `provider.tf` — Provider configurations (AzureRM).
- `backend.tf` — Terraform backend definition (for tfstate storage).
- `aks-pipeline.yml` — Azure DevOps YAML Pipeline to deploy the infrastructure.
- `README.md` — Documentation.

---

## ✅ Setup Prerequisites

Before proceeding:

Step | Description
1. Azure CLI Configured | Install and authenticate Azure CLI locally or on the agent. Install Azure CLI
2. Self-Hosted Agent (Optional) | Recommended for better control and faster execution. If parallelism is approved in Microsoft-hosted agents, self-hosted agents are not required.
3. Backend Configuration | Setup the Terraform remote backend by creating:  ➔ A Resource Group  ➔ A Storage Account  ➔ A Blob Container  ➔ A State Key (e.g., aks-cluster.terraform.tfstate)
4. Service Connection (Azure RM) | Create an App Registration (Service Principal) in Azure AD, assign it Contributor access to your subscription, and create an Azure Resource Manager Service Connection in Azure DevOps.
5. GitHub OAuth Integration | Configure GitHub OAuth in Azure DevOps to enable code synchronization and automated CI/CD triggers.

---

## 🔥 Detailed Setup Instructions

### 1. Azure Key Vault Configuration

**Azure Key Vault** is used to securely store and retrieve sensitive credentials during the pipeline run.

**Steps to configure Key Vault:**

1. **Create Key Vault:**
   ```bash
   az keyvault create --name <your-keyvault-name> --resource-group <resource-group-name> --location <location>
   ```

2. **Add Required Secrets:**
   Store the following as **secrets**:
   
   | Secret Name | Value |
   |:------------|:------|
   | ARM-CLIENT-ID | Service Principal Application (Client) ID |
   | ARM-CLIENT-SECRET | Service Principal Password/Secret |
   | ARM-SUBSCRIPTION-ID | Azure Subscription ID |
   | ARM-TENANT-ID | Azure Active Directory Tenant ID |

   Commands to add:
   ```bash
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-CLIENT-ID" --value "<client-id>"
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-CLIENT-SECRET" --value "<client-secret>"
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-SUBSCRIPTION-ID" --value "<subscription-id>"
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-TENANT-ID" --value "<tenant-id>"
   ```

3. **Configure Access Policies:**
   - Go to **Azure Portal → Key Vault → Access Policies → Add Access Policy**.
   - Permissions required:
     - **Secret Permissions:** `Get`, `List`
   - Assign access to:
     - The **Service Principal** used by your Azure DevOps Pipeline (or the pipeline agent identity).

---

### 2. Azure DevOps Service Connection Configuration

Azure DevOps needs a **Service Connection** to authenticate with Azure.

**Steps to configure:**

1. **Create a Service Principal** (if not already created):
   ```bash
   az ad sp create-for-rbac --name "<sp-name>" --role="Contributor" --scopes="/subscriptions/<subscription-id>"
   ```

2. **Create Service Connection in Azure DevOps:**
   - Navigate: **Project Settings → Service connections → New service connection → Azure Resource Manager**.
   - Choose **Service Principal (manual)**.
   - Fill in the following:
     - Subscription ID
     - Tenant ID
     - Service Principal Client ID
     - Service Principal Secret
   - **Grant access permission to all pipelines**.

✅ Ensure the service connection has **Contributor** role on the subscription or specific resource group.

---

### 3. Azure DevOps Pipeline Overview

The deployment pipeline is written in YAML (`aks-pipeline.yml`), and it automates:

| Stage | Details |
|:------|:--------|
| Install Terraform | Installs a specific version of Terraform on the Azure DevOps agent. |
| Terraform Init | Initializes the backend (Azure Storage Account) and prepares Terraform. |
| Terraform Plan | Generates an execution plan, showing what resources will be created/updated. |
| Terraform Apply | Applies the changes and provisions AKS and associated infrastructure. |

---

## 🌐 Terraform Backend Configuration

Terraform uses an **Azure Storage Account** for remote state storage to manage infrastructure state reliably.

Backend configured in `backend.tf` with:

| Parameter | Value |
|:----------|:------|
| Resource Group | `tfstate-backend-aksrg` |
| Storage Account | `tfstatebackenddanish` |
| Container Name | `tfstate` |
| State File Key | `aks-cluster.terraform.tfstate` |

Ensure:
- The Storage Account and container exist.
- The Service Principal or pipeline identity has **Storage Blob Data Contributor** permission.

---

## 🔑 Permissions Required

| Resource | Permission Needed | Purpose |
|:---------|:------------------|:--------|
| Azure Subscription | Contributor | Deploy and manage resources. |
| Key Vault | Get, List Secrets | Retrieve sensitive credentials securely. |
| Storage Account | Storage Blob Data Contributor | Manage Terraform state files. |
| Resource Group | Contributor | Create/update Azure resources. |

---

## ▶️ Running the Pipeline

Once everything is configured:

1. Push code changes to the **main** branch.
2. Azure DevOps automatically triggers the pipeline (`aks-pipeline.yml`).
3. Stages in the pipeline:
   - Terraform Initialization
   - Terraform Plan
   - Terraform Apply
4. Monitor the pipeline via Azure DevOps UI for success/failure.

---

## 📈 Best Practices and Notes

- **Use separate resource groups** for AKS and state storage for better resource isolation.
- **Lock down Key Vault access** to only pipeline identity and admin users.
- **Enable soft delete** and **purge protection** on the Key Vault and Storage Account for additional security.
- **Version lock** Terraform and provider versions for consistent deployments.
- **Consider approvals and gates** in pipelines for production environments.
- Always follow **least privilege principle** for Service Principals.

---

# 🎯 Final Objective

> Automate AKS cluster provisioning securely, reliably, and efficiently using Terraform, Azure DevOps Pipelines, and Azure Key Vault.
