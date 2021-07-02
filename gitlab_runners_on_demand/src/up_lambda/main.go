package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/autoscaling"
	log "github.com/sirupsen/logrus"
)

type toReturn struct {
	Response string `json:"response"`
}

func handle(name events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	appConfig := NewConfig()
	headers := map[string]string{
		"Access-Control-Allow-Origin":  "*",
		"Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
	}
	check, err := checkGitlabHeader(name.Headers, appConfig)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 403,
			Headers:    headers,
			Body:       "Failure to authenticate",
		}, nil
	}

	code := 202
	response, err := json.Marshal(toReturn{Response: "OK"})
	if err != nil {
		log.Error(err.Error())
		response = []byte("JSON Internal Server Error")
		code = 500
	}

	if check {
		log.Infof("Gitlab token check OK, checking ASG")
		asgErr := asgScaleCheck(appConfig)
		if asgErr != nil {
			log.Error(err.Error())
			response = []byte("ASG Internal Server Error")
			code = 500
		}
	} else {
		log.Infof("Gitlab token check failed")
		code = 403
		response, _ = json.Marshal(toReturn{Response: "Auth failed"})
	}

	return events.APIGatewayProxyResponse{
		StatusCode: code,
		Headers:    headers,
		Body:       string(response),
	}, nil
}

func main() {
	initialiseLogger()
	log.Info("Starting application...")
	lambda.Start(handle)
}

func asgScaleCheck(appConfig *config) error {

	// The below gets an AWS session
	sess := session.Must(session.NewSession(&aws.Config{
		MaxRetries: aws.Int(3),
	}))
	svc := autoscaling.New(sess, &aws.Config{
		Region: aws.String("eu-west-2"),
	})

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
			if *asg.DesiredCapacity < appConfig.UpValue {
				log.Infof("Scaling up ASG from %d to %d...", *asg.DesiredCapacity, appConfig.UpValue)
				input := autoscaling.SetDesiredCapacityInput{
					AutoScalingGroupName: &appConfig.AsgName,
					DesiredCapacity:      &appConfig.UpValue,
				}
				_, err := svc.SetDesiredCapacity(&input)
				if err != nil {
					log.Errorf("Issue with scaling up ASG: %s", err.Error())
					return err
				}
				log.Info("Done!")
			}
		}
	}
	return nil
}

func checkGitlabHeader(headers map[string]string, appConfig *config) (bool, error) {
	if val, ok := headers["X-Gitlab-Token"]; ok {
		if val != appConfig.Secret {
			return false, nil
		}
	} else {
		return false, nil
	}
	return true, nil
}
