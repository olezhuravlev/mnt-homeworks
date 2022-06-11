# Create service account to operate by Kubernetes.
resource "yandex_iam_service_account" "kubernetes-sa" {
  name        = "netology-kubernetes-sa-${terraform.workspace}"
  description = "Service account to be used by Kubernetes"
  folder_id   = yandex_resourcemanager_folder.gitlab-folder.id
}

# Grant permission "resource-manager.editor" on folder for service account.
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = yandex_resourcemanager_folder.gitlab-folder.id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.kubernetes-sa.id}"
  ]
}

# Grant permission "container-registry.images.pusher" on folder for service account.
resource "yandex_resourcemanager_folder_iam_binding" "images-pusher" {
  folder_id = yandex_resourcemanager_folder.gitlab-folder.id
  role      = "container-registry.images.pusher"
  members   = [
    "serviceAccount:${yandex_iam_service_account.kubernetes-sa.id}"
  ]
}

# Create Kubernetes cluster.
resource "yandex_kubernetes_cluster" "netology-k8s-cluster" {

  name = "netology-k8s-cluster"

  folder_id  = yandex_resourcemanager_folder.gitlab-folder.id
  network_id = yandex_vpc_network.netology-network.id

  master {
    version = "1.21"
    zonal {
      zone      = yandex_vpc_subnet.netology-subnet.zone
      subnet_id = yandex_vpc_subnet.netology-subnet.id
    }

    security_group_ids = [
      yandex_vpc_security_group.k8s-main-sg.id,
      yandex_vpc_security_group.k8s-master-whitelist.id
    ]

    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.kubernetes-sa.id
  node_service_account_id = yandex_iam_service_account.kubernetes-sa.id

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.images-pusher
  ]

  release_channel = "STABLE"
}

# Create node group.
resource "yandex_kubernetes_node_group" "netology-k8s-cluster-ng" {

  name        = "netology-k8s-cluster-ng"
  description = "Noge group for Kubernetes cluster to be used by GitLab Runner"
  version     = "1.21"

  cluster_id = yandex_kubernetes_cluster.netology-k8s-cluster.id

  instance_template {

    platform_id = local.instance_type[terraform.workspace]

    network_interface {
      subnet_ids         = [yandex_vpc_subnet.netology-subnet.id]
      nat                = true
      security_group_ids = [
        yandex_vpc_security_group.k8s-main-sg.id,
        yandex_vpc_security_group.k8s-nodes-ssh-access.id,
        yandex_vpc_security_group.k8s-public-services.id
      ]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }

    metadata = {
      ssh-keys = "${local.users[local.os]}:${file(local.pub_file_path[local.os])}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = local.instance_zone[terraform.workspace]
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
  }
}
