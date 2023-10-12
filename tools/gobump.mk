TOOL_VERSION = 1.0.0
BASE_URL = https://example.com/tool
TARGET_FILE = path_in_archive_to_file_you_want.ext  # replace with actual path to your file inside the archive

# By default, use the system's platform. But this can be overridden.
PLATFORM ?= $(shell uname -s)

ifeq ($(PLATFORM),Darwin)
    # macOS
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-macOS.tar.gz
    ARCHIVE_CMD = curl -L $(ARCHIVE_NAME) | tar xzf - -C ./bin/ $(TARGET_FILE)
endif
ifeq ($(PLATFORM),Linux)
    # Linux
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-linux.tar.gz
    ARCHIVE_CMD = curl -L $(ARCHIVE_NAME) | tar xzf - -C ./bin/ $(TARGET_FILE)
endif
ifneq (,$(or $(findstring CYGWIN,$(PLATFORM)), $(findstring MINGW,$(PLATFORM)), $(findstring MSYS,$(PLATFORM))))
    # Windows
    ARCHIVE_NAME = $(BASE_URL)-$(TOOL_VERSION)-windows.zip
    # Note: For zip you'll need a different approach to extract just one file
    ARCHIVE_CMD = curl -L -o temp.zip $(ARCHIVE_NAME) && unzip temp.zip $(TARGET_FILE) -d ./bin/ && rm temp.zip
endif

install:
	@mkdir -p ./bin
	$(ARCHIVE_CMD)
