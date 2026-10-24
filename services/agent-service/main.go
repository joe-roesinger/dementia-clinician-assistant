package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"

	"google.golang.org/genai"
)

func main() {
	_ = godotenv.Load() // Will figure out a better way to handle this.

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{})

	if err != nil {
		log.Fatal(err)
	}

	model := os.Getenv("MODEL_ID")

	if model == "" {
		log.Fatal("No model configured.")
	}

	res, err := client.Models.GenerateContent(ctx, model, genai.Text("Tell me a joke about GOlang"), nil)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(res.Text())
}
