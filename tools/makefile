OS_NAME := $(shell uname -s | tr A-Z a-z)

.PHONY: download/gobump
download/gobump:
	mkdir -p ../temp && curl -O -L --output-dir ../temp https://github.com/x-motemen/gobump/releases/download/$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_linux_amd64.tar.gz

.PHONY: extract/gobump
extract/gobump:
	tar -xzvf ../temp/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_linux_amd64.tar.gz -C ../temp

.PHONY: copy/gobump
copy/gobump:
	mkdir -p ../bin && cp ../temp/gobump_$(shell go list -m -f '{{ .Version }}' github.com/x-motemen/gobump)_linux_amd64/gobump ../bin/.

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
