//go:build tools

package tools

import (
	_ "github.com/sanemat/go-importlist/cmd/import-list"
	_ "github.com/sanemat/go-xgoinstall/cmd/x-go-install"
	_ "github.com/tcnksm/ghr"
	_ "github.com/x-motemen/gobump/cmd/gobump"
	_ "golang.org/x/lint/golint"
	_ "golang.org/x/tools/cmd/goimports"
)
