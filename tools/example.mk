TOOL_VERSION = 1.0.0
BASE_URL = https://example.com/tool
PROJECT_ROOT = $(PWD)
MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Detect platform and architecture.
PLATFORM ?= $(shell uname -s)
ARCH ?= $(shell uname -m)

# Platform-specific settings.
ifeq ($(PLATFORM),Darwin)
	EXTRACT_DIR = $(MAKEFILE_DIR)/$(shell mktemp --dry-run XXXXXX)
	TEMP_ARCHIVE_FILE = $(MAKEFILE_DIR)/$(shell mktemp --dry-run XXXXXX.tar.gz)
	UNPACK_CMD = tar -xzvf $(TEMP_ARCHIVE_FILE) -C $(EXTRACT_DIR)
	FILE_IN_ARCHIVE = path_for_mac_in_the_archive
	BIN_NAME = desired_tool_name_for_mac
else ifeq ($(PLATFORM),Linux)
	EXTRACT_DIR = $(MAKEFILE_DIR)/$(shell mktemp --dry-run XXXXXX)
	TEMP_ARCHIVE_FILE = $(MAKEFILE_DIR)/$(shell mktemp --dry-run XXXXXX.tar.gz)
	UNPACK_CMD = tar -xzvf $(TEMP_ARCHIVE_FILE) -C $(EXTRACT_DIR)
	FILE_IN_ARCHIVE = path_for_linux_in_the_archive
	BIN_NAME = desired_tool_name_for_linux
else ifneq (,$(or $(findstring CYGWIN,$(PLATFORM)), $(findstring MINGW,$(PLATFORM)), $(findstring MSYS,$(PLATFORM))))
	EXTRACT_DIR = $(MAKEFILE_DIR)/%RANDOM%_$(shell date +%s%N)
	TEMP_ARCHIVE_FILE = $(MAKEFILE_DIR)/%RANDOM%_$(shell date +%s%N).zip
	UNPACK_CMD = unzip $(TEMP_ARCHIVE_FILE) -d $(EXTRACT_DIR)
	FILE_IN_ARCHIVE = path_for_windows_in_the_archive
	BIN_NAME = desired_tool_name_for_windows
endif

# Set download command.
DOWNLOAD_CMD = curl -L -o $(TEMP_ARCHIVE_FILE) $(BASE_URL)/$(PLATFORM)/$(ARCH)/v$(TOOL_VERSION)

install:
	@if [ -z "$(PLATFORM)" ] || [ -z "$(ARCH)" ]; then \
		echo "Missing PLATFORM or ARCH, defaulting to 'go install'."; \
		go install example.com@$(TOOL_VERSION); \
		exit 0; \
	fi; \
	if $(DOWNLOAD_CMD); then \
		$(UNPACK_CMD); \
		mkdir -p $(PROJECT_ROOT)/bin; \
		mv $(EXTRACT_DIR)/$(FILE_IN_ARCHIVE) $(PROJECT_ROOT)/bin/$(BIN_NAME); \
		rm -rf $(EXTRACT_DIR); \
		rm -f $(TEMP_ARCHIVE_FILE); \
	else \
		echo "Failed to download. Falling back to 'go install'."; \
		go install example.com@$(TOOL_VERSION); \
	fi
