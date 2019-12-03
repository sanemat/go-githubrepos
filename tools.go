// +build tools

package tools

import (
	_ "github.com/Songmu/gocredits/cmd/gocredits"
	_ "github.com/Songmu/goxz/cmd/goxz"
	_ "github.com/git-chglog/git-chglog/cmd/git-chglog"
	_ "github.com/motemen/gobump/cmd/gobump"
	_ "github.com/tcnksm/ghr"
	_ "golang.org/x/lint/golint"
)
