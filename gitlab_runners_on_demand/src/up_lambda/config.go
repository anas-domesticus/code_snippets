package main

import (
	log "github.com/sirupsen/logrus"
	"os"
	"strconv"
)

type config struct {
	DownValue int64
	UpValue   int64
	AsgName   string
	Secret    string
}

func NewConfig() *config {
	envVars := [...]string{"ASGNAME", "UPVAL", "DOWNVAL", "SECRET"}
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
		DownValue: envToInt64("DOWNVAL"),
		UpValue:   envToInt64("UPVAL"),
		AsgName:   os.Getenv("ASGNAME"),
		Secret:    os.Getenv("SECRET"),
	}

	return &c
}

func envToInt64(envName string) int64 {
	n, err := strconv.ParseInt(os.Getenv(envName), 10, 64)
	if err != nil {
		log.Fatalf("%s unparseable as int64: %s", envName, os.Getenv(envName))
	}
	return n
}
