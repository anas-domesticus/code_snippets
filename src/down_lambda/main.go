package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/autoscaling"
	log "github.com/sirupsen/logrus"
	"github.com/xanzy/go-gitlab"
	"time"
)

func main() {
	lambda.Start(handle)
}

func handle() error {
	initialiseLogger()
	log.Info("Starting application...")
	appConfig := NewConfig()
	git, err := gitlab.NewClient(appConfig.Token)
	if err != nil {
		log.Fatal(err)
	} else {
		log.Info("Got Gitlab API session")
	}
	t := true
	f := false
	p, _, err := git.Projects.ListProjects(&gitlab.ListProjectsOptions{Archived: &f, Owned: &t})
	if err != nil {
		log.Fatal(fmt.Sprintf("Problem getting projects %s", err.Error()))
	}

	timeThreshold := time.Now().Add(time.Minute * time.Duration(-30))
	var scaleDown = true

	for _, v := range p {
		pl, _, err := git.Pipelines.ListProjectPipelines(v.ID, &gitlab.ListProjectPipelinesOptions{
			UpdatedAfter: &timeThreshold,
		})
		if err != nil {
			log.Fatal(fmt.Sprintf("Problem getting pipelines for project %s: %s", v.Name, err.Error()))
		}
		if len(pl) > 0 {
			log.Info(fmt.Sprintf("Project %s has recent pipelines, not going to scale down ASG", v.Name))
			scaleDown = false
		}
	}
	if scaleDown {
		err := asgScaleCheck(appConfig)
		if err != nil {
			log.Error("Problem scaling down ASG", err.Error())
		}
	}
	return nil
}

func asgScaleCheck(appConfig *config) error {

	// The below gets an AWS session
	sess := session.Must(session.NewSession(&aws.Config{
		MaxRetries: aws.Int(3),
	}))
	svc := autoscaling.New(sess, &aws.Config{
		Region: aws.String("eu-west-2"),
	})
	log.Info("AWS session established")
	// We're only looking for a single ASG here
	searchTerms := autoscaling.DescribeAutoScalingGroupsInput{
		AutoScalingGroupNames: []*string{&appConfig.AsgName},
	}

	foundAsgs, err := svc.DescribeAutoScalingGroups(&searchTerms)
	if err != nil {
		log.Errorf("Problem describing ASG: %s", err.Error())
		return err
	}

	if len(foundAsgs.AutoScalingGroups) == 0 {
		log.Infof("ASG with name %s not found", appConfig.AsgName)
	} else {
		for _, asg := range foundAsgs.AutoScalingGroups {
			if *asg.DesiredCapacity != 0 {
				log.Infof("Scaling down ASG")
				var desiredNum int64 = 0
				input := autoscaling.SetDesiredCapacityInput{
					AutoScalingGroupName: &appConfig.AsgName,
					DesiredCapacity:      &desiredNum,
				}
				_, err := svc.SetDesiredCapacity(&input)
				if err != nil {
					log.Errorf("Issue with scaling down ASG: %s", err.Error())
					return err
				}
				log.Info("Done!")
			}
		}
	}
	return nil
}
