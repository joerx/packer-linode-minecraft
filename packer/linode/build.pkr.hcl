build {
  name = "ubuntu"

  sources = [
    "source.linode.ubuntu",
  ]

  provisioner "shell" {
    execute_command = "sudo env {{ .Vars }} {{ .Path }}"

    scripts = [
      abspath("${path.root}/../scripts/setup.sh"),
      abspath("${path.root}/../scripts/cleanup.sh"),
    ]
  }

  post-processor "manifest" {}
}
