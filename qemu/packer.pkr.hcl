packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

locals {
  ubuntu_releases = {
    focal = "20.04"
    jammy = "22.04"
  }

  ubuntu_version = lookup(local.ubuntu_releases, var.ubuntu_release, "22.04")
}

variable "ubuntu_release" {
  type        = string
  default     = "jammy"
  description = "Ubuntu codename version (i.e. 20.04 is focal and 22.04 is jammy)"
}
