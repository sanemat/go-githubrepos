# githubrepos

List repos up on GitHub Organization.

## Overview

`github-repos -z --org=yourorg` returns github ssh clone url on yourorg, split by NULL.
This returns all repos.

## Limitation

Only organization. Not user.

## Usage

```
github-repos -org packsaddle -z | xargs --null -P 4 -I {} git clone {} --depth 1
```

required: `GITHUB_TOKEN=__YOUR_PERSONAL_TOKEN__`

## Motivation

There are several ways for cloning GitHub repositories in an organization.
- [How to clone all repositories in a Github Organization](https://medium.com/@kevinsimper/how-to-clone-all-repositories-in-a-github-organization-8ccc6c4bd9df)
- [Cloning All Repositories in a GitHub Organization - Scott's Weblog - The weblog of an IT pro focusing on cloud computing, Kubernetes, Linux, containers, and networking](https://blog.scottlowe.org/2018/07/19/cloning-all-repositories-in-a-github-organization/)
- [Clone all repos from a GitHub organization](https://gist.github.com/caniszczyk/3856584)

But I don't want to see my personal token for GitHub. And I want to handle pagination because my organization has over 400 repos :sweat_smile:

I tried [caarlos0/clone-org](https://github.com/caarlos0/clone-org), but sometimes I got errors.

## Install

### ghg
`ghg get sanemat/go-githubrepos`

### go get
`go get https://github.com/sanemat/go-githubrepos/cmd/github-repos
`

## Design

[design](./design.md)

## Changelog

[chagelog](./changelog.md) by [git-chglog](https://github.com/git-chglog/git-chglog)

## License

Copyright 2019 Matt (Sanemat) (Murahashi Kenichi)
[Apache License Version 2.0](./license.txt)

## Credits

[credits](./credits.txt) by [gocredits](https://github.com/Songmu/gocredits/)
