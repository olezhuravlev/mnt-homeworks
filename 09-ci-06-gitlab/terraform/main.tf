# Base Terraform definition.
terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
}

# Define provider.
provider "yandex" {
  cloud_id = var.yandex-cloud-id
  zone     = var.yandex-cloud-zone
}

# Create folder.
resource "yandex_resourcemanager_folder" "gitlab-folder" {
  cloud_id    = var.yandex-cloud-id
  name        = "gitlab-folder-${terraform.workspace}"
  description = "Netology GitLab test folder"
}

# Create Static Access Keys
#resource "yandex_iam_service_account_static_access_key" "terraform-sa-static-key" {
#  service_account_id = yandex_iam_service_account.terraform-netology-sa.id
#  description        = "Static access key for service account"
#}

# Use keys to create bucket
#resource "yandex_storage_bucket" "netology-bucket" {
#  access_key = yandex_iam_service_account_static_access_key.terraform-sa-static-key.access_key
#  secret_key = yandex_iam_service_account_static_access_key.terraform-sa-static-key.secret_key
#  bucket     = "netology-bucket-${terraform.workspace}"
#  grant {
#    id          = yandex_iam_service_account.terraform-netology-sa.id
#    type        = "CanonicalUser"
#    permissions = ["READ", "WRITE"]
#  }
#}

# Network.
resource "yandex_vpc_network" "netology-network" {
  folder_id   = yandex_resourcemanager_folder.gitlab-folder.id
  name        = "netology-network"
  description = "Netology network"
}

# Subnets of the network.
resource "yandex_vpc_subnet" "netology-subnet" {
  folder_id      = yandex_resourcemanager_folder.gitlab-folder.id
  name           = "netology-subnet-0"
  description    = "Netology subnet 0"
  v4_cidr_blocks = ["10.100.0.0/24"]
  zone           = var.yandex-cloud-zone
  network_id     = yandex_vpc_network.netology-network.id
}

# Container registry for Gitlab.
resource "yandex_container_registry" "gitlab-registry" {
  name      = "gitlab-registry"
  folder_id = yandex_resourcemanager_folder.gitlab-folder.id
  labels    = {
    my-label = "gitlab-registry"
  }
}

# Config to create Gitlab server.
module "gitlab-server" {
  source        = "./modules/instance"
  folder_id     = yandex_resourcemanager_folder.gitlab-folder.id
  subnet_id     = yandex_vpc_subnet.netology-subnet.id
  cores         = local.cores[terraform.workspace]
  core_fraction = local.core_fraction[terraform.workspace]
  memory        = local.memory[terraform.workspace]
  disk_size     = local.disk_size[terraform.workspace]
  instance_type = local.instance_type[terraform.workspace]
  nat           = true

  for_each                    = toset(["gitlab"])
  instance_name               = each.key
  image_family                = "gitlab"
  image_id                    = "fd80j61emugbtgpt85tr"
  users                       = local.users[local.os]
  pub_file_path               = local.pub_file_path[local.os]
  remote_exec_script_filename = "./modules/instance/init.sh"
}

locals {

  os = "ubuntu"

  users = {
    centos = "centos"
    ubuntu = "ubuntu"
  }

  pub_file_path = {
    centos = "~/.ssh/id_rsa.pub"
    ubuntu = "~/.ssh/id_rsa.pub"
  }

  cores = {
    default = 2
  }
  core_fraction = {
    default = "100"
  }
  memory = {
    default = 4
  }
  disk_size = {
    default = 20
  }
  instance_type = {
    default = "standard-v1"
  }
  instance_zone = {
    default = "ru-central1-a"
  }
}
