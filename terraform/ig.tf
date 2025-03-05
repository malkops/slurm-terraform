data "yandex_compute_image" "nginx" {
  name = "${var.image_name}-${var.image_tag}"
}

data "yandex_resourcemanager_folder" "slurm" {
  name = var.folder_name
}

resource "yandex_iam_service_account" "this" {
  name        = "vmmanager"
  description = "service account to manage VMs"
  folder_id   = data.yandex_resourcemanager_folder.slurm.id
}

resource "yandex_resourcemanager_folder_iam_binding" "this" {
  folder_id = data.yandex_resourcemanager_folder.slurm.id

  role = "editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}",
  ]
  depends_on  = [yandex_iam_service_account.this]
}

resource "yandex_compute_instance_group" "this" {
  depends_on          = [yandex_iam_service_account.this, yandex_resourcemanager_folder_iam_binding.this]
  name                = "nginx-ig"
  folder_id           = data.yandex_resourcemanager_folder.slurm.id
  service_account_id  = yandex_iam_service_account.this.id

  instance_template {
    platform_id = "standard-v2"
    resources {
      memory = var.resources.memory
      cores  = var.resources.cpu
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.nginx.id
        size     = var.resources.disk
      }
    }
    network_interface {
      network_id = yandex_vpc_network.this.id
      subnet_ids = values(yandex_vpc_subnet.this).*.id
    }
    metadata = {
      ssh-keys = var.public_ssh_key_path != "" ? "slurm:${file(var.public_ssh_key_path)}" : "slurm:${tls_private_key.ssh_key[0].public_key_openssh}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.ig-size
    }
  }

  allocation_policy {
    zones = var.ig-zones
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }
  application_load_balancer {
    target_group_name = "nginx-tg"
  }
}


