TOOL_VERSION = 1.0.0
BASE_URL = https://example.com/tool
PROJECT_ROOT = $(PWD)

# Detect platform and architecture.
PLATFORM ?= $(shell uname -s)
ARCH ?= $(shell uname -m)

# For macOS
ifeq ($(PLATFORM),Darwin)
    FILE_IN_ARCHIVE = nested_dir/another_dir/path_in_mac_$(ARCH)_archive
    BIN_NAME = mac_$(ARCH)_command
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-macOS-$(ARCH).tar.gz
    DOWNLOAD_AND_UNPACK = curl -L $(ARCHIVE_NAME) | tar xzf - -C $(PROJECT_ROOT)/bin $(FILE_IN_ARCHIVE)
endif

# For Linux
ifeq ($(PLATFORM),Linux)
    FILE_IN_ARCHIVE = nested_dir/another_dir/path_in_linux_$(ARCH)_archive
    BIN_NAME = linux_$(ARCH)_command
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-linux-$(ARCH).tar.gz
    DOWNLOAD_AND_UNPACK = curl -L $(ARCHIVE_NAME) | tar xzf - -C $(PROJECT_ROOT)/bin $(FILE_IN_ARCHIVE)
endif

# For Windows (Cygwin, Git Bash, MinGW, etc.)
ifneq (,$(or $(findstring CYGWIN,$(PLATFORM)), $(findstring MINGW,$(PLATFORM)), $(findstring MSYS,$(PLATFORM))))
    FILE_IN_ARCHIVE = nested_dir/another_dir/path_in_windows_$(ARCH)_archive.ext
    BIN_NAME = windows_$(ARCH)_command.exe
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-windows-$(ARCH).zip
    TEMP_ARCHIVE_FILE = %RANDOM%_$(shell date +%s%N).zip
    DOWNLOAD_AND_UNPACK = curl -L -o $(TEMP_ARCHIVE_FILE) $(ARCHIVE_NAME) && unzip $(TEMP_ARCHIVE_FILE) $(FILE_IN_ARCHIVE) -d $(PROJECT_ROOT)/bin && rm $(TEMP_ARCHIVE_FILE)
endif

install:
	@if [ -z "$(ARCH)" ] || [ -z "$(DOWNLOAD_AND_UNPACK)" ]; then \
		go install example.com@$(TOOL_VERSION); \
	else \
		mkdir -p $(PROJECT_ROOT)/bin; \
		$(DOWNLOAD_AND_UNPACK); \
		mv $(PROJECT_ROOT)/bin/$(FILE_IN_ARCHIVE) $(PROJECT_ROOT)/bin/$(BIN_NAME); \
	fi
