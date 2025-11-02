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

  post-processor "shell-local" {
    inline = [
      "IMAGE_ID=$(cat packer-manifest.json | jq -r '.builds | last | .artifact_id')",
      "curl -X PUT --url https://api.linode.com/v4/images/$${IMAGE_ID} -H 'accept: application/json' -H 'content-type: application/json' -H \"authorization: Bearer $${LINODE_TOKEN}\" --data '{\"tags\": [\"channel:${var.channel}\", \"repo:github.com/joerx/packer-linode-minecraft\"]}'"
    ]
  }
}
