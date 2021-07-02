build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 cd src; go build -o ../down_lambda ./down_lambda/*.go
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 cd src; go build -o ../up_lambda ./up_lambda/*.go
	zip down_lambda.zip down_lambda
	zip up_lambda.zip up_lambda
