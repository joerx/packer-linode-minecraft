BUILD=qemu
CHANNEL=snapshot-$(shell git rev-parse --short HEAD)

.PHONY: default
default: check-fmt clean build

.PHONY: build
build: $(BUILD)/packer-manifest.json

$(BUILD)/packer-manifest.json:
	cd $(BUILD) && packer init .
	cd $(BUILD) && packer build -var "channel=$(CHANNEL)" .

.PHONY: clean
clean:
	rm -f $(BUILD)/packer-manifest.json
	rm -rf $(BUILD)/output

.PHONY: check-fmt
check-fmt:
	cd qemu && packer fmt -check -diff .
	cd linode && packer fmt -check -diff .

.PHONY: fmt
fmt:
	cd qemu && packer fmt .
	cd linode && packer fmt .
