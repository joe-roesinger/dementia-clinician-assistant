package main

import (
	"context"
	"fmt"
	"http"
	"log"
	"os"

	"github.com/joho/godotenv"

	"google.golang.org/genai"
)

func main() {
	_ = godotenv.Load() // Will figure out a better way to handle this.

	port := os.Getenv("PORT")

	if port == "" {
		port = "8080"
	}

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{})

	if err != nil {
		log.Fatal(err)
	}

	model := os.Getenv("MODEL_ID")

	if model == "" {
		log.Fatal("No model configured.")
	}

	mux := http.NewSeveMux()

	mux.HandleFunc("GET /joke", jokeHandler)

	res, err := client.Models.GenerateContent(ctx, model, genai.Text("Tell me a joke about GOlang"), nil)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(res.Text())
}

type mystruct struct {
	model_id string
	client   *genai.Client
}

func jokeHandler(w http.ResponseWriter, r *http.Request) {

}
