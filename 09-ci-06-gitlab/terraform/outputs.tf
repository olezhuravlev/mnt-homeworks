output "yc_folder_id" {
  description = "Yandex.Cloud folder ID"
  value = yandex_resourcemanager_folder.gitlab-folder.id
}

output "kubernetes_cluster_id" {
  description = "Kubernetes cluster ID"
  value = yandex_kubernetes_cluster.netology-k8s-cluster.id
}

output "gitlab_container_registry_id" {
  description = "Gitlab container registry ID"
  value = yandex_container_registry.gitlab-registry.id
}

output "gitlab_host" {
  description = "GitLab Server external IP"
  value = module.gitlab-server
}
