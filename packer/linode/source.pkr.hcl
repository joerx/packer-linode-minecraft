source "linode" "ubuntu" {
  image             = "linode/ubuntu${local.ubuntu_version}"
  image_description = "Base image for minecraft servers."
  image_label       = "mc-base-ubuntu${local.ubuntu_version}-${local.label}"
  image_regions     = local.regions
  instance_label    = "mc-tmp-pkr-ubuntu-${local.ubuntu_version}-${local.label}-${local.timestamp}"
  instance_type     = "g6-nanode-1"
  linode_token      = "${var.linode_api_token}"
  region            = local.regions[0]
  ssh_username      = "root"
  instance_tags     = ["managed-by:packer", "channel:${var.channel}", "build:ubuntu${local.ubuntu_version}"]

  metadata {
    user_data = base64encode(file(abspath("${path.root}/../init/user-data")))
  }
}
