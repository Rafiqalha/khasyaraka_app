package main

import (
	"context"
	"fmt"
	"log"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/core/llm/deepseek"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("API KEY:", cfg.DeepSeekAPIKey)

	adapter := deepseek.NewAdapter(cfg.DeepSeekAPIKey, cfg.DeepSeekModel)

	fmt.Println("Calling DeepSeek...")
	resp, promptTokens, completionTokens, err := adapter.GenerateJSON(
		context.Background(),
		"You are an assistant. Output MUST be valid JSON.",
		"Tell me a Pythone in 1 sentence.",
	)

	if err != nil {
		log.Fatalf("Error: %v", err)
	}

	fmt.Printf("Success! Tokens: %d prompt, %d completion\n", promptTokens, completionTokens)
	fmt.Println("Response:", resp)
}
