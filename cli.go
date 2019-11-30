package githubrepos

import (
	"flag"
	"fmt"
	"io"
	"log"

	"golang.org/x/xerrors"
)

const cmdName = "github-repos"
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
