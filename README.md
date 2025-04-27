Of course! 🙌  
Here’s your full `README.md` with the **Setup Prerequisites** section properly formatted into a clean table, along with small polishings to the whole file for better presentation:

---

# 🚀 AKS Provisioning with Terraform and Azure DevOps Pipelines

This repository demonstrates **end-to-end automation** for deploying an **Azure Kubernetes Service (AKS)** cluster using **Terraform**, integrated with **Azure DevOps Pipelines** for continuous infrastructure delivery.  

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [Setup Prerequisites](#-setup-prerequisites)
- [Detailed Setup Instructions](#-detailed-setup-instructions)
  - [Azure Key Vault Configuration](#1-azure-key-vault-configuration)
  - [Azure DevOps Service Connection Configuration](#2-azure-devops-service-connection-configuration)
  - [Azure DevOps Pipeline Overview](#3-azure-devops-pipeline-overview)
- [Terraform Backend Configuration](#-terraform-backend-configuration)
- [Permissions Required](#-permissions-required)
- [Running the Pipeline](#-running-the-pipeline)
- [Best Practices and Notes](#-best-practices-and-notes)

---

## 🧩 Overview

This project provisions the following infrastructure on Azure:

- An **Azure Kubernetes Service (AKS)** Cluster.
- Associated resources like **Virtual Networks**, **Subnets**, and **Managed Identities** (depending on the Terraform modules).

The entire deployment is automated via **Azure DevOps Pipelines**, using **Azure Key Vault** for secret management and **Azure Storage Account** for remote state management.

---

## 📂 Repository Structure

> ✅ All code and pipeline YAML definitions are located directly under the `main` branch.

```bash
├── main.tf            # Main Terraform configuration
├── variables.tf       # Terraform input variables
├── outputs.tf         # Terraform outputs
├── provider.tf        # Provider settings (AzureRM)
├── backend.tf         # Remote backend configuration for Terraform state
├── aks-pipeline.yml   # Azure DevOps pipeline definition
├── README.md          # Documentation
```

---

## ✅ Setup Prerequisites

Before you begin, ensure you have completed the following:

| Step | Description |
|:----:|:------------|
| **1. Azure CLI Configured** | Install and authenticate [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) locally or on the agent. |
| **2. Self-Hosted Agent (Optional)** | Recommended for better control and faster execution. If parallelism is approved, a Microsoft-hosted agent can also be used. |
| **3. Backend Configuration** | Setup the Terraform backend: <br> ➔ Create a Resource Group <br> ➔ Create a Storage Account <br> ➔ Create a Blob Container <br> ➔ Define a State File (e.g., `aks-cluster.terraform.tfstate`) |
| **4. Service Connection (Azure RM)** | Create a Service Principal (App Registration), assign it the **Contributor** role on the subscription, and create an **Azure Resource Manager** service connection in Azure DevOps. |
| **5. GitHub OAuth Integration** | Configure GitHub OAuth in Azure DevOps to synchronize the codebase and trigger pipelines automatically. |

---

## 🔥 Detailed Setup Instructions

### 1. Azure Key Vault Configuration

Azure Key Vault securely stores sensitive credentials used during pipeline execution.

#### Steps:

1. **Create a Key Vault**:
   ```bash
   az keyvault create --name <your-keyvault-name> --resource-group <resource-group-name> --location <location>
   ```

2. **Add Required Secrets**:
   ```bash
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-CLIENT-ID" --value "<client-id>"
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-CLIENT-SECRET" --value "<client-secret>"
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-SUBSCRIPTION-ID" --value "<subscription-id>"
   az keyvault secret set --vault-name <your-keyvault-name> --name "ARM-TENANT-ID" --value "<tenant-id>"
   ```

3. **Configure Access Policies**:
   - Go to **Azure Portal → Key Vault → Access Policies → Add Access Policy**.
   - Permissions required:
     - **Secret Permissions:** `Get`, `List`
   - Assign access to the **Service Principal** used by your Azure DevOps Pipeline.

---

### 2. Azure DevOps Service Connection Configuration

Azure DevOps requires a Service Connection to deploy Azure resources.

#### Steps:

1. **Create a Service Principal**:
   ```bash
   az ad sp create-for-rbac --name "<sp-name>" --role="Contributor" --scopes="/subscriptions/<subscription-id>"
   ```

2. **Create Azure DevOps Service Connection**:
   - Navigate to: **Project Settings → Service Connections → New connection → Azure Resource Manager**.
   - Choose **Service Principal (manual)** authentication.
   - Provide:
     - Subscription ID
     - Tenant ID
     - Service Principal Client ID
     - Service Principal Secret
   - **Enable access to all pipelines**.

---

### 3. Azure DevOps Pipeline Overview

The deployment pipeline is defined in the `aks-pipeline.yml` file.

| Stage | Description |
|:------|:------------|
| Install Terraform | Install specific version of Terraform on agent. |
| Terraform Init | Initialize the Terraform backend (Azure Storage Account). |
| Terraform Plan | Create an execution plan to preview changes. |
| Terraform Apply | Apply infrastructure changes to Azure. |

---

## 🌐 Terraform Backend Configuration

Terraform uses Azure Storage Account for remote state management.

Backend settings defined in `backend.tf`:

| Parameter | Value |
|:----------|:------|
| Resource Group | `tfstate-backend-aksrg` |
| Storage Account | `tfstatebackenddanish` |
| Container Name | `tfstate` |
| State File Key | `aks-cluster.terraform.tfstate` |

Ensure:
- Storage account and container are created.
- Service Principal or agent identity has **Storage Blob Data Contributor** permissions.

---

## 🔑 Permissions Required

| Azure Resource | Permission Needed | Purpose |
|:---------------|:------------------|:--------|
| Azure Subscription | Contributor | Manage and deploy resources. |
| Key Vault | Secrets: Get, List | Retrieve sensitive credentials. |
| Storage Account | Storage Blob Data Contributor | Manage Terraform state files. |
| Resource Group | Contributor | Provision resources. |

---

## ▶️ Running the Pipeline

Once setup is completed:

1. Push changes to the **main** branch.
2. Azure DevOps triggers the `aks-pipeline.yml`.
3. Pipeline Stages:
   - **Terraform Init**
   - **Terraform Plan**
   - **Terraform Apply**
4. Monitor pipeline execution through the Azure DevOps portal.

---

## 📈 Best Practices and Notes

- Use separate resource groups for AKS and Terraform state.
- Enable **soft delete** and **purge protection** on both Key Vault and Storage Account.
- Lock down Key Vault access to only required identities.
- Always version lock Terraform and Azure Provider versions.
- Apply **least privilege principle** for Service Principals and agents.
- Use pipeline approval gates for production deployments.

---

# 🎯 Final Objective

> Automate AKS cluster provisioning **securely**, **reliably**, and **efficiently** using Terraform, Azure DevOps Pipelines, and Azure Key Vault integration.

---
