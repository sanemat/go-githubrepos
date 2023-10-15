UNAME_S := $(shell uname -s)
ifeq ($(OS),Windows_NT)
    EXTENSION=.exe
else
    EXTENSION=
endif

.PHONY: download/gobump
download/gobump:
	mkdir -p ../temp && curl -O -L --output-dir ../temp https://github.com/x-motemen/gobump/releases/download/$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_$(OS_PATH)_$(ARCH_NAME).$(ARCHIVE_EXT)

ifeq ($(OS_NAME), linux)
.PHONY: extract/gobump
extract/gobump:
	tar -xzvf ../temp/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_$(OS_PATH)_$(ARCH_NAME).$(ARCHIVE_EXT) -C ../temp
else
.PHONY: extract/gobump
extract/gobump:
	unzip ../temp/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_$(OS_PATH)_$(ARCH_NAME).$(ARCHIVE_EXT) -d ../temp
endif

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
