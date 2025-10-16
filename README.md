# Packer Build for Linode Minecraft Images

This repo contains Packer build definitions for a Ubuntu-based server image running a vanilla Minecraft server.

## Preconditions

- Linux based host system with KVM
- Working libvirt and QEMU install
- Good intro [here](https://www.youtube.com/watch?v=HfNKpT2jo7U)

## Usage

Default target is to lint the source files and run a clean build on QEMU:

```sh
make
```

## Releases

> [!INFO]
> Releases are private only, you need your own Linode API token for cloud builds.

- `mc-server-<os-variant>-stable` - Stable version, currently non existent
- `mc-server-<os-variant>-edge` - Tracking `main`, for sandbox, testing and development
- `mc-server-<os-variant>-dev-<branch-name>` - Tracking development branches, for testing
- `mc-server-<os-variant>-snapshot-<commit-ref>` - Local development builds
- See [build.yaml](.github/workflows/build.yaml) for details

## Terraform

```tf
variable "channel" {
  default = "edge"
}

data "linode_images" "latest" {
  latest = true

  filter {
    name   = "label"
    values = ["mc-ubuntu22.04-${var.channel}"]
  }

  filter {
    name   = "is_public"
    values = ["false"]
  }
}
```

See [here](./examples/terraform/) for a complete example.