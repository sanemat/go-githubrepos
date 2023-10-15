MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
TOOL_VERSION := $(shell cd $(MAKEFILE_DIR) && go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)
BASE_URL := https://github.com/x-motemen/gobump/releases/download
PROJECT_ROOT := $(PWD)

# Detect platform and architecture.
PLATFORM ?= $(shell uname -s)
ARCH ?= $(shell uname -m)

# Decide filepath from arch
ifeq ($(ARCH),x86_64)
    ARCHPATH := amd64
else ifeq ($(ARCH),aarch64)
    ARCHPATH := arm64
else ifeq ($(ARCH),i686)
    ARCHPATH := x86
else ifeq ($(ARCH),i386)
    ARCHPATH := x86
endif

# Platform-specific settings.
ifeq ($(PLATFORM),Darwin)
    TARGET_PATH := $(TOOL_VERSION)/gobump_$(TOOL_VERSION)_linux_$(ARCHPATH).tar.gz
    EXTRACT_DIR := $(MAKEFILE_DIR)$(shell mktemp --dry-run XXXXXX)
    TEMP_ARCHIVE_FILE := $(MAKEFILE_DIR)$(shell mktemp --dry-run XXXXXX.tar.gz)
    UNPACK_CMD := tar -xzvf $(TEMP_ARCHIVE_FILE) -C $(EXTRACT_DIR)
    FILE_IN_ARCHIVE := path_for_mac_in_the_archive
    BIN_NAME := desired_tool_name_for_mac
else ifeq ($(PLATFORM),Linux)
    TARGET_PATH := $(TOOL_VERSION)/gobump_$(TOOL_VERSION)_linux_$(ARCHPATH).tar.gz
    EXTRACT_DIR := $(MAKEFILE_DIR)$(shell mktemp --dry-run XXXXXX)
    TEMP_ARCHIVE_FILE := $(MAKEFILE_DIR)$(shell mktemp --dry-run XXXXXX.tar.gz)
    UNPACK_CMD := tar -xzvf $(TEMP_ARCHIVE_FILE) -C $(EXTRACT_DIR)
    FILE_IN_ARCHIVE := gobump_$(TOOL_VERSION)_linux_$(ARCHPATH)/gobump
    BIN_NAME := gobump
else ifneq (,$(or $(findstring CYGWIN,$(PLATFORM)), $(findstring MINGW,$(PLATFORM)), $(findstring MSYS,$(PLATFORM))))
    TARGET_PATH := $(TOOL_VERSION)/gobump_$(TOOL_VERSION)_linux_$(ARCHPATH).tar.gz
    EXTRACT_DIR := $(MAKEFILE_DIR)%RANDOM%_$(shell date +%s%N)
    TEMP_ARCHIVE_FILE := $(MAKEFILE_DIR)%RANDOM%_$(shell date +%s%N).zip
    UNPACK_CMD := unzip $(TEMP_ARCHIVE_FILE) -d $(EXTRACT_DIR)
    FILE_IN_ARCHIVE := path_for_windows_in_the_archive
    BIN_NAME := desired_tool_name_for_windows
endif

# Set download command.
DOWNLOAD_CMD := curl -L -o $(TEMP_ARCHIVE_FILE) $(BASE_URL)/$(TARGET_PATH)

install:
	@if [ -z "$(PLATFORM)" ] || [ -z "$(ARCH)" ]; then \
		echo "Missing PLATFORM or ARCH, defaulting to 'go install'."; \
		go install github.com/x-motemen/gobump/cmd/gobump@$(TOOL_VERSION); \
		exit 0; \
	fi; \
	if $(DOWNLOAD_CMD); then \
        mkdir -p $(EXTRACT_DIR); \
		$(UNPACK_CMD); \
		mkdir -p $(PROJECT_ROOT)/bin; \
		mv $(EXTRACT_DIR)/$(FILE_IN_ARCHIVE) $(PROJECT_ROOT)/bin/$(BIN_NAME); \
		rm -rf $(EXTRACT_DIR); \
		rm -f $(TEMP_ARCHIVE_FILE); \
	else \
		echo "Failed to download. Falling back to 'go install'."; \
		go install github.com/x-motemen/gobump/cmd/gobump@$(TOOL_VERSION); \
	fi
