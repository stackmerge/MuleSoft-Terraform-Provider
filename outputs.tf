output "omni_gateway_id" {
 value = anypoint_managed_omni_gateway.demo.id
}

output "omni_gateway_status" {
 value = anypoint_managed_omni_gateway.demo.status
}

output "jsonplaceholder_api_instance_id" {
 value = anypoint_api_instance.jsonplaceholder_users_api.id
}

output "jsonplaceholder_api_instance_status" {
 value = anypoint_api_instance.jsonplaceholder_users_api.status
}

output "jsonplaceholder_api_base_path" {
 value = "/jsonplaceholder-users"
}
