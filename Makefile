# ZMK Firmware Build System for Charybdis Keyboard
# Based on Kinesis Advantage 360 Pro build system

# Detect container runtime (prefer podman if available)
CONTAINER_ENGINE := $(shell command -v podman 2> /dev/null || echo docker)

# Build configuration
BOARD := nice_nano_v2
SHIELD_LEFT := charybdis_left
SHIELD_RIGHT := charybdis_right
CONFIG_DIR := config
FIRMWARE_DIR := firmware
IMAGE_NAME := zmk-charybdis

# Container mount options (handle SELinux on Linux)
MOUNT_OPTS := $(shell if [ "$$(uname)" = "Linux" ]; then echo ":z"; fi)

# Build targets
.PHONY: all left right clean clean_firmware clean_image version

all: left right settings_reset

left: version
	@echo "Building left half firmware..."
	@mkdir -p $(FIRMWARE_DIR)
	$(CONTAINER_ENGINE) run --rm \
		-v $(PWD)/$(CONFIG_DIR):/app/config$(MOUNT_OPTS) \
		-v $(PWD)/$(FIRMWARE_DIR):/app/firmware$(MOUNT_OPTS) \
		-e SIDE=left \
		-e SHIELD=$(SHIELD_LEFT) \
		-e BOARD=$(BOARD) \
		$(IMAGE_NAME)

right: version
	@echo "Building right half firmware..."
	@mkdir -p $(FIRMWARE_DIR)
	$(CONTAINER_ENGINE) run --rm \
		-v $(PWD)/$(CONFIG_DIR):/app/config$(MOUNT_OPTS) \
		-v $(PWD)/$(FIRMWARE_DIR):/app/firmware$(MOUNT_OPTS) \
		-e SIDE=right \
		-e SHIELD=$(SHIELD_RIGHT) \
		-e BOARD=$(BOARD) \
		$(IMAGE_NAME)

settings_reset: version
	@echo "Building settings reset firmware..."
	@mkdir -p $(FIRMWARE_DIR)
	$(CONTAINER_ENGINE) run --rm \
		-v $(PWD)/$(CONFIG_DIR):/app/config$(MOUNT_OPTS) \
		-v $(PWD)/$(FIRMWARE_DIR):/app/firmware$(MOUNT_OPTS) \
		-e SIDE=reset \
		-e SHIELD=settings_reset \
		-e BOARD=$(BOARD) \
		$(IMAGE_NAME)

# Build the Docker image
build-image:
	@echo "Building ZMK Docker image..."
	$(CONTAINER_ENGINE) build -t $(IMAGE_NAME) .

# Generate version info
version:
	@echo "Generating version info..."
	@echo "$(shell date -u +"%Y-%m-%d %H:%M:%S UTC")" > $(CONFIG_DIR)/version.txt
	@echo "$(shell git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" >> $(CONFIG_DIR)/version.txt

# Clean targets
clean_firmware:
	@echo "Cleaning firmware directory..."
	rm -rf $(FIRMWARE_DIR)

clean_image:
	@echo "Removing Docker image..."
	$(CONTAINER_ENGINE) rmi $(IMAGE_NAME) 2>/dev/null || true

clean: clean_firmware clean_image
	@echo "Cleaning version info..."
	rm -f $(CONFIG_DIR)/version.txt

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build both left and right halves + settings reset"
	@echo "  left         - Build only left half"
	@echo "  right        - Build only right half"
	@echo "  settings_reset - Build settings reset firmware"
	@echo "  build-image  - Build the Docker image"
	@echo "  clean        - Clean everything"
	@echo "  clean_firmware - Clean only firmware files"
	@echo "  clean_image  - Remove Docker image"
	@echo "  help         - Show this help message"