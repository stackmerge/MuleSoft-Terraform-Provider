# ---------------------------------------------------------
# Tells Terraform that this script needs Terraform CLI version 
# 1.5.0 or higher.
# Tells Terraform to download the MuleSoft Anypoint provider 
# from the Terraform registry.
# ---------------------------------------------------------
terraform {
 required_version = ">= 1.5.0"

 required_providers {
   anypoint = {
     source  = "mulesoft/anypoint"
     version = "~> 1.0"
   }
 }
}

# ---------------------------------------------------------
# Starts provider configuration for Anypoint Platform.
# ---------------------------------------------------------
provider "anypoint" {
 client_id     = var.anypoint_client_id
 client_secret = var.anypoint_client_secret
 base_url      = var.anypoint_base_url
 auth_type     = "connected_app"
}

# ---------------------------------------------------------
# Managed Omni Gateway
# ---------------------------------------------------------
resource "anypoint_managed_omni_gateway" "demo" {
 name            = var.gateway_name
 organization_id = var.organization_id
 environment_id  = var.environment_id
 target_id       = var.private_space_id

 release_channel = "lts"
 size            = "small"

 ingress = {
   forward_ssl_session = true
   last_mile_security  = true
 }

 properties = {
   upstream_response_timeout = 15
   connection_idle_timeout   = 60
 }

 logging = {
   level        = "info"
   forward_logs = true
 }

 tracing = {
   enabled = false
 }
}

# ---------------------------------------------------------
# API Instance
# ---------------------------------------------------------
resource "anypoint_api_instance" "jsonplaceholder_users_api" {
 organization_id = var.organization_id
 environment_id  = var.environment_id

 # Existing Managed Omni Gateway created by Terraform
 gateway_id = anypoint_managed_omni_gateway.demo.id

 technology     = "omniGateway"
 instance_label = "jsonplaceholder-users-api"

 # Upstream backend API
 upstream_uri = "https://jsonplaceholder.typicode.com/users"

 # API asset reference in Exchange/API Manager
 spec = {
   asset_id = var.api_asset_id
   group_id = var.organization_id
   version  = var.api_asset_version
 }

 endpoint = {
   type      = "http"
   base_path = "jsonplaceholder-users"
 }


#Forces Terraform to create the Omni Gateway before creating the API instance.
 depends_on = [
   anypoint_managed_omni_gateway.demo
 ]
}

# ---------------------------------------------------------
# Policy 1: Client ID Enforcement
# ---------------------------------------------------------
resource "anypoint_api_policy_client_id_enforcement" "jsonplaceholder_client_id_enforcement" {
 organization_id = var.organization_id
 environment_id  = var.environment_id
 api_instance_id = anypoint_api_instance.jsonplaceholder_users_api.id

 label = "client-id-enforcement"
 order = 1

 configuration = {
   credentials_origin_has_http_basic_authentication_header = "customExpression"

   # API consumer must send these headers
   client_id_expression     = "#[attributes.headers['client_id']]"
   client_secret_expression = "#[attributes.headers['client_secret']]"
 }

 depends_on = [
   anypoint_api_instance.jsonplaceholder_users_api
 ]
}

# ---------------------------------------------------------
# Policy 2: Rate Limiting
# ---------------------------------------------------------
resource "anypoint_api_policy_rate_limiting" "jsonplaceholder_rate_limiting" {
 organization_id = var.organization_id
 environment_id  = var.environment_id
 api_instance_id = anypoint_api_instance.jsonplaceholder_users_api.id

 label = "rate-limit-10-per-minute"
 order = 2

 configuration = {
   rate_limits = [
     {
       maximum_requests            = var.rate_limit_max_requests
       time_period_in_milliseconds = var.rate_limit_time_period_ms
     }
   ]

   # Rate limit per client_id header.
   # Since Client ID Enforcement already requires client_id,
   # this keeps rate limiting client-specific.
   key_selector = "#[attributes.headers['client_id']]"

   expose_headers = true
   clusterizable  = true
 }

 depends_on = [
   anypoint_api_policy_client_id_enforcement.jsonplaceholder_client_id_enforcement
 ]
}
