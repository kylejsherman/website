package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
)

func listTables(c *gin.Context) {

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		log.Fatalf("Unable to load SDK config, %v", err)
	}

	ddbClient := dynamodb.NewFromConfig(cfg)

	resp, err := ddbClient.ListTables(context.TODO(), &dynamodb.ListTablesInput{
		Limit: aws.Int32(5),
	})
	if err != nil {
		log.Fatalf("Unable to list tabels, %v", err)
	}

}

func main() {
	router := gin.Default()

	router.GET("/listTables", listTables)
	// router.Run("localhost:8080")
}
