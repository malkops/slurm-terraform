variable "image_name" {
  type        = string
  description = "The image name"
  default = "test"
}

variable "image_tag" {
  type        = string
  description = "The image tag"
  default = "1"
}

variable "folder_name" {
  type        = string
  description = "Folder name"
  default     = "slurm-terraform-base"
}

variable "labels" {
  type = map(string)
  default = {
    project = "slurm"
    env = "final"
  }
}

variable "resources" {
  type = object({cpu = number, memory = number, disk = number})
  default = {
    cpu = 2
    memory = 2
    disk = 4
  }
}

variable "cidr_blocks" {
  type = list(list(string))
  default = [ [ "10.2.0.0/16" ], ["10.3.0.0/16"], ["10.4.0.0/16"] ]
}

variable "nlb_port" {
  type = number
  default = 80
}

variable "nlb_healthcheck" {
  type = object({
    name = string
    port = number
    path = string
  })
  default = {
    name = "test"
    port = 80
    path = "/"
  }
}

variable "public_ssh_key_path" {
  type = string
  default = ""
}

variable "az" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b", "ru-central1-d" ]
}

variable "ig-size" {
  type = number
  default = 1
}

variable "ig-zones" {
  type = list(string)
  default = [ "ru-central1-a" ]
}

