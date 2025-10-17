BUILD=qemu
CHANNEL=snapshot-$(shell git rev-parse --short HEAD)

.PHONY: default
default: check-fmt clean build

.PHONY: build
build: packer/$(BUILD)/packer-manifest.json

packer/$(BUILD)/packer-manifest.json:
	packer init packer/$(BUILD)
	packer build -var "channel=$(CHANNEL)" packer/$(BUILD) 

.PHONY: clean
clean:
	find packer -type d -name output -exec rm -rf {} \;
	find packer -name 'packer-manifest.json' -exec rm {} \;

# Don't use `-exec` below since it will ignrore non-zero exit codes
.PHONY: check-fmt
check-fmt:
	find packer -name '*.pkr.hcl' | xargs -n1 packer fmt -check -diff

.PHONY: fmt
fmt:
	find packer -name '*.pkr.hcl' | xargs -n1 packer fmt
