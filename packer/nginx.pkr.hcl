variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = env("YC_ZONE")
}

variable "YC_SUBNET_ID" {
  type = string
  default = env("YC_SUBNET_ID")
}

variable "image_tag" {
  type = string
  default = "1"
}

source "yandex" "nginx-centos" {
  folder_id           = "${var.YC_FOLDER_ID}"
  source_image_family = "centos-stream-9-oslogin"
  ssh_username        = "centos"
  use_ipv4_nat        = "true"
  image_description   = "Image with nginx based on CentOS 9"
  image_family        = "malkov-nginx"
  image_name          = "nginx-${var.image_tag}"
  subnet_id           = "${var.YC_SUBNET_ID}"
  disk_type           = "network-hdd"
  zone                = "${var.YC_ZONE}"
}

build {
  sources = ["source.yandex.nginx-centos"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False"]

  }
}

