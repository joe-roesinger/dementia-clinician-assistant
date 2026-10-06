output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for api in google_project_service.apis : api.service]
}

output "service_url" {
  description = "Service URL"
  value       = google_cloud_run_v2_service.agent.uri
}