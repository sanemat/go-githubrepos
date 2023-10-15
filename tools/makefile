MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: install/gobump
install/gobump:
	make -f gobump.mk install

.PHONY: install-tools
install-tools: install/gobump

.PHONY: go/mod/tidy
go/mod/tidy:
	cd $(MAKEFILE_DIR); \
	go mod tidy -compat=$(shell go list -m -f {{.GoVersion}})
