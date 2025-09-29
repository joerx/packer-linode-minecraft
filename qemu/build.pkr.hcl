build {
  name = "ubuntu"

  sources = [
    "source.qemu.ubuntu",
  ]

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"

    scripts = [
      "../scripts/setup.sh",
      "../scripts/cleanup.sh",
    ]
  }

  post-processor "manifest" {
    custom_data = {
      ubuntu_release = var.ubuntu_release
      ubuntu_version = local.ubuntu_version
    }
  }
}
