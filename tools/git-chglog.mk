MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST))) # include trailing slash
TOOL_VERSION := $(shell cd $(MAKEFILE_DIR) && go list -m -f '{{ .Version }}' github.com/git-chglog/git-chglog)
BASE_URL := https://github.com/git-chglog/git-chglog/releases/download/v0.15.4/git-chglog_0.15.4_darwin_amd64.tar.gz
PROJECT_ROOT := $(PWD)
GO_INSTALL_URL := github.com/git-chglog/git-chglog/cmd/git-chglog@$(TOOL_VERSION)

# Detect platform and architecture.
PLATFORM ?= $(shell uname -s)
ARCH ?= $(shell uname -m)

# Decide filepath from arch
ifeq ($(ARCH),x86_64)
    ARCHPATH := amd64
else ifeq ($(ARCH),aarch64)
    ARCHPATH := arm64
else ifeq ($(ARCH),i686)
    ARCHPATH := 386
else ifeq ($(ARCH),i386)
    ARCHPATH := 386
else ifeq ($(ARCH),armv6l)  # armv6 usually reports as armv6l
    ARCHPATH := armv6
endif

# Platform-specific settings.
ifeq ($(PLATFORM),Darwin)
    TARGET_PATH := $(TOOL_VERSION)/git-chglog_$(TOOL_VERSION)_darwin_$(ARCHPATH).tar.gz
    EXTRACT_DIR := $(MAKEFILE_DIR)$(shell mktemp --dry-run tempXXXXXX)
    TEMP_ARCHIVE_FILE := $(MAKEFILE_DIR)$(shell mktemp --dry-run tempXXXXXX.tar.gz)
    UNPACK_CMD := tar -xzvf $(TEMP_ARCHIVE_FILE) -C $(EXTRACT_DIR)
    FILE_IN_ARCHIVE := git-chglog_$(TOOL_VERSION)_darwin_$(ARCHPATH)/gobump
    BIN_NAME := git-chglog
else ifeq ($(PLATFORM),Linux)
    TARGET_PATH := $(TOOL_VERSION)/git-chglog_$(TOOL_VERSION)_linux_$(ARCHPATH).tar.gz
    EXTRACT_DIR := $(MAKEFILE_DIR)$(shell mktemp --dry-run tempXXXXXX)
    TEMP_ARCHIVE_FILE := $(MAKEFILE_DIR)$(shell mktemp --dry-run tempXXXXXX.tar.gz)
    UNPACK_CMD := tar -xzvf $(TEMP_ARCHIVE_FILE) -C $(EXTRACT_DIR)
    FILE_IN_ARCHIVE := git-chglog_$(TOOL_VERSION)_linux_$(ARCHPATH)/git-chglog
    BIN_NAME := git-chglog
else ifneq (,$(or $(findstring CYGWIN,$(PLATFORM)), $(findstring MINGW,$(PLATFORM)), $(findstring MSYS,$(PLATFORM))))
    TARGET_PATH := $(TOOL_VERSION)/git-chglog_$(TOOL_VERSION)_windows_$(ARCHPATH).zip
    EXTRACT_DIR := $(MAKEFILE_DIR)temp%RANDOM%_$(shell date +%s%N)
    TEMP_ARCHIVE_FILE := $(MAKEFILE_DIR)temp%RANDOM%_$(shell date +%s%N).zip
    UNPACK_CMD := unzip $(TEMP_ARCHIVE_FILE) -d $(EXTRACT_DIR)
    FILE_IN_ARCHIVE := git-chglog_$(TOOL_VERSION)_windows_$(ARCHPATH)/git-chglog.exe
    BIN_NAME := git-chglog.exe
endif

# Set download command.
DOWNLOAD_CMD := curl -L -o $(TEMP_ARCHIVE_FILE) $(BASE_URL)/$(TARGET_PATH)

install:
	@if [ -z "$(PLATFORM)" ] || [ -z "$(ARCH)" ] || [ -z "$(ARCHPATH)" ]; then \
		echo "Missing PLATFORM or ARCH, defaulting to 'go install'."; \
		go install $(GO_INSTALL_URL); \
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
		go install $(GO_INSTALL_URL); \
	fi
