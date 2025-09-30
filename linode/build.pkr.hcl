build {
  name = "ubuntu"

  sources = [
    "source.linode.ubuntu",
  ]

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"

    scripts = [
      "../scripts/setup.sh",
      "../scripts/cleanup.sh",
    ]
  }

  post-processor "manifest" {}
}
