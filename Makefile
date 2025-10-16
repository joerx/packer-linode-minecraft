BUILD=qemu
CHANNEL=snapshot-$(shell git rev-parse --short HEAD)

.PHONY: default
default: check-fmt clean build

.PHONY: build
build: packer/$(BUILD)/packer-manifest.json

packer/$(BUILD)/packer-manifest.json:
	cd $(BUILD) && packer init .
	cd $(BUILD) && packer build -var "channel=$(CHANNEL)" .

.PHONY: clean
clean:
	find packer -name 'packer-manifest.json' -exec rm {} \;

.PHONY: check-fmt
check-fmt:
	find packer -name '*.pkr.hcl' -exec packer fmt -check -diff {} \;

.PHONY: fmt
fmt:
	find packer -name '*.pkr.hcl' -exec packer fmt {} \;
