variable "os_variant" {
  default = "ubuntu22.04"
}

variable "channel" {
  default = "edge"
}

# This will return all private images matching the given label
data "linode_images" "all" {
  filter {
    name   = "label"
    values = ["mc-${var.os_variant}-${var.channel}"]
  }

  filter {
    name   = "is_public"
    values = ["false"]
  }
}

# This will return the latest private image matching the given label
data "linode_images" "latest" {
  latest = true

  filter {
    name   = "label"
    values = ["mc-${var.os_variant}-${var.channel}"]
  }

  filter {
    name   = "is_public"
    values = ["false"]
  }
}

output "all_image_ids" {
  value = data.linode_images.all.images.*.id
}

output "latest_image_id" {
  value = data.linode_images.latest.images.*.id
}
