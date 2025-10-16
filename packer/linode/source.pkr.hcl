source "linode" "ubuntu" {
  image             = "linode/ubuntu${local.ubuntu_version}"
  image_description = "Base image for minecraft servers."
  image_label       = "mc-server-ubuntu${local.ubuntu_version}-${var.channel}"
  image_regions     = local.regions
  instance_label    = "mc-temp-packer-ubuntu${local.ubuntu_version}-${var.channel}-${local.timestamp}"
  instance_type     = "g6-nanode-1"
  linode_token      = "${var.linode_api_token}"
  region            = local.regions[0]
  ssh_username      = "root"
  instance_tags     = ["managed-by:packer", "channel:${var.channel}", "build:ubuntu${local.ubuntu_version}"]

  metadata {
    user_data = base64encode(file("${path.root}/../init/user-data"))
  }
}
