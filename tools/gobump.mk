TOOL_VERSION = $(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)
BASE_URL = https://github.com/x-motemen/gobump/releases/download/$(TOOL_VERSION)
PROJECT_ROOT = $(PWD)

# Detect platform and architecture.
PLATFORM ?= $(shell uname -s)
ARCH ?= $(shell uname -m)

# Define file in archive and binary name based on platform and architecture
ifeq ($(PLATFORM),Darwin)
    FILE_IN_ARCHIVE = path_in_mac_$(ARCH)_archive
    BIN_NAME = mac_$(ARCH)_command
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-macOS-$(ARCH).tar.gz
    ARCHIVE_CMD = curl -L $(ARCHIVE_NAME) | tar xzf - -C $(PROJECT_ROOT)/bin/ $(FILE_IN_ARCHIVE)
endif
ifeq ($(PLATFORM),Linux)
    FILE_IN_ARCHIVE = path_in_linux_$(ARCH)_archive
    BIN_NAME = linux_$(ARCH)_command
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-linux-$(ARCH).tar.gz
    ARCHIVE_CMD = curl -L $(ARCHIVE_NAME) | tar xzf - -C $(PROJECT_ROOT)/bin/ $(FILE_IN_ARCHIVE)
endif
ifeq ($(PLATFORM),Windows)
    FILE_IN_ARCHIVE = path_in_windows_$(ARCH)_archive.ext
    BIN_NAME = windows_$(ARCH)_command.exe
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-windows-$(ARCH).zip
    ZIP_NAME = tool_$(TOOL_VERSION)_$(ARCH)_$(shell date +%s).zip
    ARCHIVE_CMD = curl -L -o $(ZIP_NAME) $(ARCHIVE_NAME) && unzip $(ZIP_NAME) -d $(PROJECT_ROOT)/bin/ $(FILE_IN_ARCHIVE)
endif

install:
	@if [ -z "$(ARCH)" ] || [ -z "$(ARCHIVE_CMD)" ]; then \
		go install example.com@$(TOOL_VERSION); \
	else \
		mkdir -p $(PROJECT_ROOT)/bin; \
		$(ARCHIVE_CMD); \
		mv $(PROJECT_ROOT)/bin/$(FILE_IN_ARCHIVE) $(PROJECT_ROOT)/bin/$(BIN_NAME); \
	fi
