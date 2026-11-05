package main

import (
	"context"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"

	"google.golang.org/genai"
)

func main() {
	_ = godotenv.Load() // TODO Will figure out a better way to handle this?

	port := os.Getenv("PORT")

	if port == "" {
		port = "8080"
	}

	ctx := context.Background()

	client, err := genai.NewClient(ctx, &genai.ClientConfig{})

	if err != nil {
		log.Fatal(err)
	}

	modelId := os.Getenv("MODEL_ID")

	if modelId == "" {
		log.Fatal("No modelId configured.")
	}

	aiClient := &AiClient{modelId: modelId, client: client}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /joke", aiClient.jokeHandler)
	mux.HandleFunc("GET /healthz", healthzHandler)

	log.Printf("listening on port %s", port)

	err = http.ListenAndServe(":"+port, mux)

	if err != nil {
		log.Fatal(err)
	}
}

type AiClient struct {
	modelId string
	client  *genai.Client
}

func (ai *AiClient) jokeHandler(w http.ResponseWriter, r *http.Request) {
	res, err := ai.client.Models.GenerateContent(r.Context(), ai.modelId, genai.Text("Tell me a joke about GOlang"), nil)

	if err != nil { // TODO Should move this into more reusable err handling once multiple endpoitns
		http.Error(w, "Error talking with "+ai.modelId, http.StatusInternalServerError)
		log.Println(err.Error())
		return
	}

	io.WriteString(w, res.Text())
}

func healthzHandler(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "ok")
}
