packer {
  required_plugins {
    linode = {
      version = ">= 1.0.1"
      source  = "github.com/linode/linode"
    }
  }
}

locals {
  ubuntu_releases = {
    focal = "20.04"
    jammy = "22.04"
  }

  ubuntu_version = lookup(local.ubuntu_releases, var.ubuntu_release, "22.04")
  timestamp      = regex_replace(timestamp(), "[- TZ:]", "")
  regions        = ["eu-central"]
  label          = substr(var.channel, 0, 25)
}

variable "linode_api_token" {
  type    = string
  default = env("LINODE_TOKEN")
}

variable "channel" {
  type        = string
  default     = "dev"
  description = "Channel name to tag the image with (e.g. stable, dev, etc)"
}

variable "ubuntu_release" {
  type        = string
  default     = "jammy"
  description = "Ubuntu codename version (i.e. 20.04 is focal and 22.04 is jammy)"
}
