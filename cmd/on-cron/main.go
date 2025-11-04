package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/adhocore/gronx"
)

var (
	version = "dev"
	branch  = "unknown"
	commit  = "unknown"
)

func printUsage() {
	fmt.Printf("on-cron %s - Check if a cron expression is currently due\n\n", version)
	fmt.Printf("Usage: %s [options] <expression>\n\n", os.Args[0])
	flag.PrintDefaults()
	fmt.Println("\nExit codes: 0=due, 1=not due, 2=invalid")
}

func printVersion() {
	fmt.Printf("on-cron %s\n", version)
	fmt.Printf("Build info: version: %s, branch: %s, commit: %s\n", version, branch, commit)
}

func main() {
	showVersion := flag.Bool("v", false, "show version information")
	quiet := flag.Bool("q", false, "quiet mode")
	flag.Usage = printUsage
	flag.Parse()

	if *showVersion {
		printVersion()
		os.Exit(0)
	}

	args := flag.Args()
	if len(args) != 1 {
		if !*quiet {
			printUsage()
		}
		os.Exit(2)
	}

	gron := gronx.New()
	if !gron.IsValid(args[0]) {
		if !*quiet {
			fmt.Fprintf(os.Stderr, "Error: Invalid cron expression: %s\n", args[0])
		}
		os.Exit(2)
	}

	isDue, err := gron.IsDue(args[0])
	if err != nil {
		if !*quiet {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		}
		os.Exit(2)
	}

	if isDue {
		os.Exit(0)
	}
	os.Exit(1)
}
