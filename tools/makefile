OS_NAME := $(shell uname -s | tr A-Z a-z)
ARCH_NAME := amd64
ifeq ($(OS_NAME), linux)
	OS_PATH := linux
else ifeq ($(OS_NAME), darwin)
	OS_PATH := darwin
else
	OS_PATH := windows
endif
ifeq ($(OS_NAME), linux)
	ARCHIVE_EXT := "tar.gz"
else
	ARCHIVE_EXT := "zip"
endif

.PHONY: download/gobump
download/gobump:
	mkdir -p ../temp && curl -O -L --output-dir ../temp https://github.com/x-motemen/gobump/releases/download/$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_$(OS_PATH)_$(ARCH_NAME).$(ARCHIVE_EXT)

.PHONY: extract/gobump
extract/gobump:
	tar -xzvf ../temp/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_$(OS_PATH)_$(ARCH_NAME).$(ARCHIVE_EXT) -C ../temp

.PHONY: copy/gobump
copy/gobump:
	mkdir -p ../bin && cp ../temp/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_$(OS_PATH)_$(ARCH_NAME)/gobump ../bin/.

.PHONY: install/gobump
install/gobump: download/gobump extract/gobump copy/gobump

.PHONY: install-tools
install-tools: install/gobump

.PHONY: go/mod/tidy
go/mod/tidy:
	go mod tidy -compat=$(shell go list -m -f {{.GoVersion}})

.PHONY: echo/os-name
echo/os-name:
	echo $(OS_NAME)
