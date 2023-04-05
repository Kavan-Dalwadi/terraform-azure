# Azure services required (Prerequisites)
- Azure Key Value: To add SSL certificate for the domain
- Azure Storage account: To store terraform state file
- Azure Service Principal: To access azure services in CICD pipeline

## Creating service principal using Azure cli
Install Azure cli from- https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

First login into Azure account
```
$ az login
```
Create Azure service principal
> This command saves it output in azure_auth_sp.json.
```
$ az ad sp create-for-rbac --name YourServicePrincipalName --skip-assignment --sdk-auth > azure_auth_sp.json
```
If you skip --sdk-auth argument the output will look like the following:
```
{
  "appId": "12345678-1111-2222-3333-1234567890ab",
  "displayName": "localtest-sp-rbac",
  "name": "http://localtest-sp-rbac",
  "password": "abcdef00-4444-5555-6666-1234567890ab",
  "tenant": "00112233-7777-8888-9999-aabbccddeeff"
}
```
Note here, in this case, tenant is the tenant ID, appId is the client ID, and password is the client secret.
If you don't skip --sdk-auth argument the output will look like the following:
```
{
  "clientId": "12345678-1111-2222-3333-1234567890ab",
  "clientSecret": "abcdef00-4444-5555-6666-1234567890ab",
  "subscriptionId": "00000000-0000-0000-0000-000000000000",
  "tenantId": "00112233-7777-8888-9999-aabbccddeeff",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

# Azure Services created using Terraform

## Services created by terraform in DEV-India resource-group
- Azure Kubernetes service
- Azure Container registry
- Azure SQL Server 
- Azure SQL Database
- Azure Public IP Prefix

## Services created and managed  by terraform/kubernetes
- New Resource Group: "dev-terraform-managed-aks-rg"
- Application Gateway
- Virtual Machine Scale Set
- Virtual Network
- Loadbalancer
- Public IP address
- Route tables
- Network Security Group

## Commands to create Infrastructure using Terraform

Install Terraform CLI from-
https://developer.hashicorp.com/terraform/downloads?product_intent=terraform

To initialize & download the provider & modules
```
$ terraform init
```
To check & validate the syntax (lint)
```
$ terraform validate
```
To check which resources will be created
```
$ terraform plan
``` 
- adding variables from tfvars file
```
$ terraform plan -var-file=filename.tfvars
```
To provision infrastructure
```
$ terraform apply
```
- adding variables from tfvars file
```
$ terraform apply -var-file=filename.tfvars
```

### How to generate K8s dashboard token for read-only access

> First connect AKS cluster to local terminal and check K8s dashboard is deployed or not.

```
$ kubectl -n kubernetes-dashboard create token developer
```