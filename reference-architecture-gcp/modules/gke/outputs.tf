output "loadbalancer" {
  value = google_compute_address.public_ingress.address

  depends_on = [helm_release.ingress_nginx]
}

output "project_id" {
  value = var.project_id
}

output "name" {
  value = google_container_cluster.gke.name
}

output "cluster_type" {
  value = "gke"
}

output "zone" {
  value = var.region
}

output "credentials" {
  value     = base64decode(google_service_account_key.gke_cluster_access_key.private_key)
  sensitive = true
}

output "cluster_name" {
  value = google_container_cluster.gke.name
}

output "cluster_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = base64decode(google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
}

output "gar_repository_id" {
  value = var.gar_repository_id == null ? "" : google_artifact_registry_repository.repo[0].id
}
