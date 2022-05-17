# Base Terraform definition.
terraform {
  required_providers {
    yandex = {
      source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13.1"
}

# Define provider.
provider "yandex" {
  cloud_id = var.yandex-cloud-id
  zone     = var.yandex-cloud-zone
}

# Create folder.
resource "yandex_resourcemanager_folder" "ansible-folder" {
  cloud_id    = var.yandex-cloud-id
  name        = "ansible-${terraform.workspace}-folder"
  description = "Test folder for Ansible project"
}

# Create service account.
#resource "yandex_iam_service_account" "terraform-ansible-sa" {
#  folder_id   = yandex_resourcemanager_folder.ansible-folder.id
#  name        = "terraform-ansible-sa-${terraform.workspace}"
#  description = "Service account to be used by Terraform"
#}

# Grant permission "storage.editor" on folder "yandex-folder-id" for service account.
#resource "yandex_resourcemanager_folder_iam_member" "terraform-ansible-storage-editor" {
#  folder_id = yandex_resourcemanager_folder.ansible-folder.id
#  role      = "storage.admin"
#  member    = "serviceAccount:${yandex_iam_service_account.terraform-ansible-sa.id}"
#}

# Create Static Access Keys
#resource "yandex_iam_service_account_static_access_key" "terraform-sa-static-key" {
#  service_account_id = yandex_iam_service_account.terraform-ansible-sa.id
#  description        = "Static access key for service account"
#}

# Use keys to create bucket
#resource "yandex_storage_bucket" "ansible-bucket" {
#  access_key = yandex_iam_service_account_static_access_key.terraform-sa-static-key.access_key
#  secret_key = yandex_iam_service_account_static_access_key.terraform-sa-static-key.secret_key
#  bucket     = "ansible-bucket-${terraform.workspace}"
#  grant {
#    id          = yandex_iam_service_account.terraform-ansible-sa.id
#    type        = "CanonicalUser"
#    permissions = ["READ", "WRITE"]
#  }
#}

# Network.
resource "yandex_vpc_network" "ansible-network" {
  folder_id   = yandex_resourcemanager_folder.ansible-folder.id
  name        = "ansible-network"
  description = "Ansible network"
}

# Subnets of the network.
resource "yandex_vpc_subnet" "ansible-subnet" {
  folder_id      = yandex_resourcemanager_folder.ansible-folder.id
  name           = "ansible-subnet-0"
  description    = "Ansible subnet 0"
  v4_cidr_blocks = ["10.100.0.0/24"]
  zone           = var.yandex-cloud-zone
  network_id     = yandex_vpc_network.ansible-network.id
}

# Declare instance.
module "vm-test-count" {
  source        = "./modules/instance"
  folder_id     = yandex_resourcemanager_folder.ansible-folder.id
  subnet_id     = yandex_vpc_subnet.ansible-subnet.id
  nat           = true
  for_each      = toset(["clickhouse", "vector", "lighthouse"])
  instance_name = "vm-${each.key}"
}
