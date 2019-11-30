package main

import (
	"flag"
	"log"
	"os"

	"github.com/sanemat/go-githubrepos"
)

func main() {
	log.SetFlags(0)
	err := githubrepos.Run(os.Args[1:], os.Stdout, os.Stderr)
	if err != nil && err != flag.ErrHelp {
		log.Println(err)
		exitCode := 1
		if ecoder, ok := err.(interface{ ExitCode() int }); ok {
			exitCode = ecoder.ExitCode()
		}
		os.Exit(exitCode)
	}
}
