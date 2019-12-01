package githubrepos

import (
	"context"
	"flag"
	"fmt"
	"io"
	"log"

	"github.com/shurcooL/githubv4"
	"golang.org/x/oauth2"
	"golang.org/x/xerrors"
)

const cmdName = "github-repos"

// EnvGitHubTokenKey Key of GitHub Token on environment variables
const EnvGitHubTokenKey = "GITHUB_TOKEN"

// Run command
func Run(argv []string, token string, outStream, errStream io.Writer) error {
	log.SetOutput(errStream)
	log.SetPrefix(fmt.Sprintf("[%s] ", cmdName))
	nameAndVer := fmt.Sprintf("%s (v%s rev:%s)", cmdName, version, revision)
	fs := flag.NewFlagSet(nameAndVer, flag.ContinueOnError)
	fs.SetOutput(errStream)
	fs.Usage = func() {
		fmt.Fprintf(fs.Output(), "Usage of %s:\n", nameAndVer)
		fs.PrintDefaults()
	}

	if token == "" {
		return xerrors.Errorf("%s is required", EnvGitHubTokenKey)
	}

	var (
		ver           = fs.Bool("version", false, "display version")
		nullSeparator = fs.Bool("z", false, "use null separator")
		org           = fs.String("org", "github", "GitHub organization")
		num           = fs.Int("num", 100, "repos per request")
	)

	if err := fs.Parse(argv); err != nil {
		return err
	}
	if *ver {
		return printVersion(outStream)
	}

	argv = fs.Args()
	if len(argv) >= 1 {
		return xerrors.New("We have no subcommand")
	}

	src := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	httpClient := oauth2.NewClient(context.Background(), src)
	client := githubv4.NewClient(httpClient)

	repos, err := fetchRepos(context.Background(), *client, *org, *num)
	if err != nil {
		return err
	}
	fmt.Print(repos)

	if *nullSeparator {
		fmt.Print("Use null separator")
	}

	return nil
}

type repo struct {
	SSHURL string
}

func fetchRepos(ctx context.Context, client githubv4.Client, org string, num int) ([]repo, error) {
	var q struct {
		Organization struct {
			Repositories struct {
				Nodes    []repo
				PageInfo struct {
					EndCursor   string
					HasNextPage bool
				}
			} `graphql:"repositories(first: $first, after: $repositoriesCursor)"`
		} `graphql:"organization(login: $login)"`
	}
	variables := map[string]interface{}{
		"login":              githubv4.String(org),
		"first":              githubv4.Int(num),
		"repositoriesCursor": (*githubv4.String)(nil), // Null after argument to get first page.
	}
	var allRepos []repo
	for {
		err := client.Query(ctx, &q, variables)
		if err != nil {
			return allRepos, err
		}
		allRepos = append(allRepos, q.Organization.Repositories.Nodes...)
		if !q.Organization.Repositories.PageInfo.HasNextPage {
			break
		}
		variables["repositoriesCursor"] = githubv4.NewString(githubv4.String(q.Organization.Repositories.PageInfo.EndCursor))
	}
	return allRepos, nil
}

func printVersion(out io.Writer) error {
	_, err := fmt.Fprintf(out, "%s v%s (rev:%s)\n", cmdName, version, revision)
	return err
}
