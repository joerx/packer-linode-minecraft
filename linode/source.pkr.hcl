source "linode" "ubuntu" {
  image             = "linode/ubuntu${local.ubuntu_version}"
  image_description = "Base image for minecraft servers."
  image_label       = "mc-ubuntu${local.ubuntu_version}-${local.timestamp}"
  image_regions     = ["eu-central", "ap-south"]
  instance_label    = "mc-temp-packer-ubuntu${local.ubuntu_version}-${local.timestamp}"
  instance_type     = "g6-nanode-1"
  linode_token      = "${var.linode_api_token}"
  region            = "eu-central"
  ssh_username      = "root"
  instance_tags     = ["managed-by:packer", "stage:dev", "build:ubuntu${local.ubuntu_version}"]

  metadata {
    user_data = base64encode(file("${path.root}/../init/user-data"))
  }
}
