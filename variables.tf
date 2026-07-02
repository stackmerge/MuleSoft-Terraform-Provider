variable "anypoint_client_id" {
 description = "Anypoint Connected App Client ID"
 type        = string
 sensitive   = true
}

variable "anypoint_client_secret" {
 description = "Anypoint Connected App Client Secret"
 type        = string
 sensitive   = true
}

variable "anypoint_base_url" {
 description = "Anypoint Platform base URL"
 type        = string
 default     = "https://anypoint.mulesoft.com"
}

variable "organization_id" {
 description = "Anypoint Organization / Business Group ID"
 type        = string
}

variable "environment_id" {
 description = "Anypoint Environment ID"
 type        = string
}

variable "private_space_id" {
 description = "CloudHub 2.0 Private Space ID used as target_id"
 type        = string
}

variable "gateway_name" {
 description = "Managed Omni Gateway name"
 type        = string
 default     = "demo-managed-omni-gateway"
}

variable "api_asset_id" {
 description = "Exchange/API Manager asset ID for the API"
 type        = string
 default     = "jsonplaceholder-users-api"
}

variable "api_asset_version" {
 description = "API asset version"
 type        = string
 default     = "1.0.0"
}

variable "rate_limit_max_requests" {
 description = "Maximum number of requests allowed in the configured time window"
 type        = number
 default     = 10
}

variable "rate_limit_time_period_ms" {
 description = "Rate limit time window in milliseconds"
 type        = number
 default     = 60000
}

variable "external_client_provider_id" {
 description = "External Client Provider ID"
 type        = string
}
