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
		org           = fs.String("org", "", "GitHub organization")
	)

	if err := fs.Parse(argv); err != nil {
		return err
	}
	if *ver {
		return printVersion(outStream)
	}

	src := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	httpClient := oauth2.NewClient(context.Background(), src)
	client := githubv4.NewClient(httpClient)
	var query struct {
		Viewer struct {
			Login     githubv4.String
			CreatedAt githubv4.DateTime
		}
	}
	err := client.Query(context.Background(), &query, nil)
	if err != nil {
		return err
	}
	fmt.Println("    Login:", query.Viewer.Login)
	fmt.Println("CreatedAt:", query.Viewer.CreatedAt)

	if *nullSeparator {
		fmt.Print("Use null separator")
	}

	fmt.Print(*org)

	argv = fs.Args()
	if len(argv) >= 1 {
		return xerrors.New("We have no subcommand")
	}

	return nil
}

func printVersion(out io.Writer) error {
	_, err := fmt.Fprintf(out, "%s v%s (rev:%s)\n", cmdName, version, revision)
	return err
}
