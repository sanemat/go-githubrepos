package githubrepos

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"

	"github.com/shurcooL/githubv4"
	"golang.org/x/oauth2"
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
		return fmt.Errorf("%s is required", EnvGitHubTokenKey)
	}

	var (
		ver             = fs.Bool("version", false, "display version")
		nullTerminators = fs.Bool("z", false, "use NULs as output field terminators")
		org             = fs.String("org", "", "GitHub organization")
		num             = fs.Int("num", 100, "repos per request")
		searchQuery     = fs.String("search", "", "GitHub search query")
	)

	if err := fs.Parse(argv); err != nil {
		return err
	}
	if *ver {
		return printVersion(outStream)
	}
	if *searchQuery == "" && *org != "" {
		v := fmt.Sprintf("org:%s", *org)
		searchQuery = &v
	}

	if *searchQuery == "" {
		return errors.New("search or org is required")
	}

	argv = fs.Args()
	if len(argv) >= 1 {
		return errors.New("it has no subcommand")
	}

	src := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	httpClient := oauth2.NewClient(context.Background(), src)
	client := githubv4.NewClient(httpClient)

	repos, err := fetchRepos(context.Background(), *client, *searchQuery, *num)
	if err != nil {
		return err
	}

	if *nullTerminators {
		last := len(repos) - 1
		for i, r := range repos {
			fmt.Fprint(outStream, r.SSHURL)
			if i != last {
				fmt.Fprint(outStream, "\x00")
			}
		}
	} else {
		last := len(repos) - 1
		for i, r := range repos {
			if i == last {
				fmt.Fprint(outStream, r.SSHURL)
			} else {
				fmt.Fprintln(outStream, r.SSHURL)
			}
		}
	}

	return nil
}

type repo struct {
	SSHURL string
}

func fetchRepos(ctx context.Context, client githubv4.Client, searchQuery string, num int) ([]repo, error) {
	var q struct {
		Search struct {
			PageInfo struct {
				EndCursor   string
				HasNextPage bool
			}
			Edges []struct {
				Node struct {
					Repository repo `graphql:"... on Repository"`
				}
			}
		} `graphql:"search(query: $searchQuery, type: REPOSITORY, first: $first, after: $repositoriesCursor)"`
	}
	variables := map[string]interface{}{
		"searchQuery":        githubv4.String(searchQuery),
		"first":              githubv4.Int(num),
		"repositoriesCursor": (*githubv4.String)(nil), // Null after argument to get first page.
	}
	var allRepos []repo
	for {
		err := client.Query(ctx, &q, variables)
		if err != nil {
			return allRepos, err
		}
		for _, edge := range q.Search.Edges {
			allRepos = append(allRepos, edge.Node.Repository)
		}
		if !q.Search.PageInfo.HasNextPage {
			break
		}
		variables["repositoriesCursor"] = githubv4.NewString(githubv4.String(q.Search.PageInfo.EndCursor))
	}
	return allRepos, nil
}

func printVersion(out io.Writer) error {
	_, err := fmt.Fprintf(out, "%s v%s (rev:%s)\n", cmdName, version, revision)
	return err
}
