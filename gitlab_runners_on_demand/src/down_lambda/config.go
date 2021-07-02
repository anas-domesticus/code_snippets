package main

import (
	log "github.com/sirupsen/logrus"
	"os"
)

type config struct {
	Token   string
	AsgName string
}

func NewConfig() *config {
	envVars := [...]string{"GITLABTOKEN", "ASGNAME"}
	var fatalError = false
	for _, v := range envVars {
		_, varPresent := os.LookupEnv(v)
		if !(varPresent) {
			log.Error("Missing " + v + " environment variable")
			fatalError = true
		}
	}
	if fatalError {
		os.Exit(1)
	}

	c := config{
		Token:   os.Getenv("GITLABTOKEN"),
		AsgName: os.Getenv("ASGNAME"),
	}

	return &c
}
