VERSION = $(shell go run github.com/x-motemen/gobump/cmd/gobump@v0.2.0 show -r)
CURRENT_REVISION = $(shell git rev-parse --short HEAD)
BUILD_LDFLAGS = "-s -w -X github.com/sanemat/go-githubrepos.revision=$(CURRENT_REVISION)"
u := $(if $(update),-u)

.PHONY: test
test: download
	go test

.PHONY: download
download:
	go mod download && \
	go mod tidy

echo:
	echo ${VERSION} ${BUILD_LDFLAGS}

.PHONY: build
build: download
	go build -ldflags=$(BUILD_LDFLAGS) ./cmd/github-repos

.PHONY: install
install: download
	go install -ldflags=$(BUILD_LDFLAGS) ./cmd/github-repos

.PHONY: crossbuild
crossbuild:
	go run github.com/Songmu/goxz/cmd/goxz@v0.9.1 -pv=v$(VERSION) -build-ldflags=$(BUILD_LDFLAGS) \
      -os=linux,darwin,windows -d=./dist/v$(VERSION) ./cmd/*

.PHONY: upload
upload:
	go run github.com/tcnksm/ghr@v0.16.0 v$(VERSION) dist/v$(VERSION)

.PHONY: credits.txt
credits.txt:
	go run github.com/Songmu/gocredits/cmd/gocredits@v0.3.0 . > credits.txt

.PHONY: changelog
changelog:
	go run github.com/git-chglog/git-chglog/cmd/git-chglog@v0.15.4 -o changelog.md --next-tag v$(VERSION)
