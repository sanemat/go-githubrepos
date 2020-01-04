.PHONY: install-tools
install-tools:
	go install \
	github.com/sanemat/go-xgoinstall/cmd/x-go-install \
	github.com/sanemat/go-importlist/cmd/import-list \
	; \
	import-list -z tools.go | x-go-install -0
