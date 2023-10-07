//go:build tools

package tools

import (
	_ "github.com/git-chglog/git-chglog/cmd/git-chglog"
	_ "github.com/sanemat/go-importlist/cmd/import-list"
	_ "github.com/sanemat/go-xgoinstall/cmd/x-go-install"
	_ "github.com/tcnksm/ghr"
	_ "golang.org/x/lint/golint"
	_ "golang.org/x/tools/cmd/goimports"
)
