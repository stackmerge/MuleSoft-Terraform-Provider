# MuleSoft Managed Omni Gateway with Terraform

This repository contains a simple Terraform-based use case to provision and configure a **MuleSoft Managed Omni Gateway** on Anypoint Platform, expose a sample upstream HTTP API, and apply inbound security and traffic-control policies.


## YouTube Tutorial

Watch the complete walkthrough here:

[Build MuleSoft Managed Omni Gateway with Terraform](https://youtu.be/KM9dqF_RlkE)

## Use Case Summary

The Terraform configuration deploys the following Anypoint Platform resources:

1. **Managed Omni Gateway** on CloudHub 2.0 private space.
2. **API Manager API instance** deployed to the Omni Gateway.
3. **Upstream API routing** to:

   ```text
   https://jsonplaceholder.typicode.com/users
   ```

4. **Client ID Enforcement policy** to allow access only from approved client applications.
5. **Rate Limiting policy** to control the number of requests accepted within a configured time window.

## Request Flow

```text
Client / Consumer Application
        |
        v
Managed Omni Gateway Endpoint
        |
        v
Client ID Enforcement Policy
        |
        v
Rate Limiting Policy
        |
        v
Upstream API
https://jsonplaceholder.typicode.com/users
```

## Repository Structure

```text
.
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── README.md
```

## File Responsibilities

| File | Responsibility |
|---|---|
| `main.tf` | Defines the Anypoint provider, Managed Omni Gateway, API instance, upstream routing, and API policies. |
| `variables.tf` | Declares reusable input variables such as organization ID, environment ID, private space ID, gateway name, and rate limit values. |
| `terraform.tfvars` | Supplies actual environment-specific values for the declared variables. Do not commit real secrets to GitHub. |
| `outputs.tf` | Prints useful values after deployment, such as gateway ID, API instance ID, API status, and base path. |

## Prerequisites

Before running Terraform, make sure you have the following:

- Terraform CLI installed on your machine.
- Anypoint Platform access.
- Anypoint Connected App with client credentials.
- Required permissions to manage Runtime Manager, API Manager, and Managed Omni Gateway resources.
- Existing CloudHub 2.0 Private Space.
- Managed Omni Gateway entitlement available in the selected business group/environment.
- API asset available in Exchange/API Manager for the API instance reference.

## Install Terraform on macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version
```

## Terraform Provider

This project uses the MuleSoft Anypoint Terraform provider:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    anypoint = {
      source  = "mulesoft/anypoint"
      version = "~> 1.0"
    }
  }
}
```

## Configuration

Update `terraform.tfvars` with your actual Anypoint Platform values.

```hcl
anypoint_client_id     = "YOUR_CONNECTED_APP_CLIENT_ID"
anypoint_client_secret = "YOUR_CONNECTED_APP_CLIENT_SECRET"

anypoint_base_url = "https://anypoint.mulesoft.com"

organization_id  = "YOUR_ORG_OR_BUSINESS_GROUP_ID"
environment_id   = "YOUR_ENVIRONMENT_ID"
private_space_id = "YOUR_CLOUDHUB_2_PRIVATE_SPACE_ID"

gateway_name = "demo-managed-omni-gateway"

api_asset_id      = "jsonplaceholder-users-api"
api_asset_version = "1.0.0"

rate_limit_max_requests   = 10
rate_limit_time_period_ms = 60000
```

For the EU control plane, use:

```hcl
anypoint_base_url = "https://eu1.anypoint.mulesoft.com"
```

## Important Security Note

Do not commit real secrets to GitHub.

Recommended approach:

1. Commit a placeholder file such as `terraform.tfvars.example`.
2. Add the real `terraform.tfvars` file to `.gitignore`.
3. Store secrets in GitHub Actions secrets, HashiCorp Vault, or your enterprise secret manager.

Suggested `.gitignore` entries:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
terraform.tfvars
crash.log
crash.*.log
```

> Note: Many teams commit `.terraform.lock.hcl` for provider version reproducibility. If your team follows that practice, remove `.terraform.lock.hcl` from `.gitignore`.

## Deploy Resources

Run the commands below from the repository root.

### 1. Initialize Terraform

```bash
terraform init
```

This downloads the MuleSoft Anypoint provider and prepares the project.

### 2. Format Terraform Files

```bash
terraform fmt
```

This formats all Terraform files consistently.

### 3. Validate Configuration

```bash
terraform validate
```

This checks the Terraform syntax and provider configuration.

### 4. Review Execution Plan

```bash
terraform plan
```

This shows what Terraform will create, update, or delete.

### 5. Apply Configuration

```bash
terraform apply
```

Type `yes` when Terraform asks for confirmation.

## Expected Deployment Result

After a successful deployment, Terraform should create:

- Managed Omni Gateway.
- API instance named similar to `jsonplaceholder-users-api`.
- API route with base path:

  ```text
  /jsonplaceholder-users
  ```

- Client ID Enforcement policy.
- Rate Limiting policy.

The final consumer URL will be based on your Managed Omni Gateway hostname:

```text
https://<your-managed-omni-gateway-host>/jsonplaceholder-users
```

## Test the API

### Test Without Client Credentials

```bash
curl https://<your-managed-omni-gateway-host>/jsonplaceholder-users
```

Expected result:

```text
401 Unauthorized
```

### Test With Client Credentials

```bash
curl https://<your-managed-omni-gateway-host>/jsonplaceholder-users \
  -H "client_id: YOUR_CLIENT_ID" \
  -H "client_secret: YOUR_CLIENT_SECRET"
```

Expected result:

```json
[
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret"
  }
]
```

### Test Rate Limiting

The default configuration allows:

```text
10 requests per 60000 milliseconds
```

That means:

```text
10 requests per minute
```

Send more than 10 requests within 60 seconds using the same `client_id`.

Expected result after the limit is exceeded:

```text
429 Too Many Requests
```

## Client Application Contract Requirement

For Client ID Enforcement to work end to end, create or approve a client application contract for this API instance in Anypoint Platform.

High-level steps:

1. Go to Anypoint Platform.
2. Open API Manager.
3. Select the deployed API instance.
4. Create or approve an application contract.
5. Use the generated `client_id` and `client_secret` while invoking the API.

## Terraform Outputs

After `terraform apply`, the configured outputs may show values such as:

```text
omni_gateway_id = "..."
omni_gateway_status = "..."
jsonplaceholder_api_instance_id = "..."
jsonplaceholder_api_instance_status = "..."
jsonplaceholder_api_base_path = "/jsonplaceholder-users"
```

## Update Rate Limit

To change the rate limit, update `terraform.tfvars`:

```hcl
rate_limit_max_requests   = 100
rate_limit_time_period_ms = 60000
```

Then run:

```bash
terraform plan
terraform apply
```

## Destroy Resources

To remove the resources created by this project:

```bash
terraform destroy
```

Type `yes` when prompted.

Use this carefully, especially in shared Anypoint environments.

## Troubleshooting

### 1. Provider Download Fails

Run:

```bash
terraform init -upgrade
```

Also confirm that your internet connection can reach the Terraform Registry.

### 2. Authentication Fails

Check:

- Connected App client ID.
- Connected App client secret.
- Connected App scopes and permissions.
- Correct Anypoint base URL.

### 3. Environment or Private Space Not Found

Check:

- `organization_id`
- `environment_id`
- `private_space_id`
- Business group context
- User or Connected App access to the target environment

### 4. API Asset Not Found

Check that the API asset exists in Exchange/API Manager with the same:

- `asset_id`
- `group_id`
- `version`

### 5. Client ID Enforcement Returns 401

Check:

- Client application contract is created and approved.
- Correct `client_id` header is sent.
- Correct `client_secret` header is sent.
- Policy expressions match the actual request headers.

### 6. Rate Limit Does Not Behave as Expected

Check:

- Rate limit policy is applied to the correct API instance.
- Request is using the same `client_id`.
- `rate_limit_max_requests` and `rate_limit_time_period_ms` values are correct.
- Gateway and API instance are in active/running state.

## References

- [MuleSoft Terraform Provider - Resources](https://docs.mulesoft.com/mulesoft-terraform-provider/resources)
- [Managed Omni Gateway Resources](https://docs.mulesoft.com/mulesoft-terraform-provider/managed-gateway-resources)
- [API Manager Resources](https://docs.mulesoft.com/mulesoft-terraform-provider/api-manager-resources)
- [Client ID Enforcement Policy](https://docs.mulesoft.com/gateway/latest/policies-included-client-id-enforcement)
- [Rate Limiting Policy](https://docs.mulesoft.com/gateway/latest/policies-included-rate-limiting)
- [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)

## Summary

This project demonstrates a simple but production-relevant MuleSoft API gateway automation pattern:

```text
Terraform
  -> Managed Omni Gateway
  -> API Manager API Instance
  -> Upstream API Routing
  -> Client ID Enforcement
  -> Rate Limiting
```

It is useful for MuleSoft platform teams, integration architects, and DevOps engineers who want to manage Anypoint Platform gateway configuration using infrastructure as code.
