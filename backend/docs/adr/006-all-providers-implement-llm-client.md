# ADR-006: Every AI Provider Must Implement llm.Client

## Status
Accepted

## Context
Pradigi currently uses DeepSeek for its AI features. However, the AI landscape moves rapidly. Tomorrow, a new model from OpenAI, Anthropic, or Google might offer better reasoning or lower latency. We cannot afford to rewrite our internal services (Director, Tutor, Coach) every time we switch providers.

## Decision
We enforce an **Adapter Pattern** for all LLM interactions. 
There must be a core interface `llm.Client` (e.g., in `internal/core/llm/client.go`). 

Any new AI provider must implement this interface (e.g., `internal/core/llm/deepseek/adapter.go`, `internal/core/llm/gemini/adapter.go`). The internal services will only depend on the `llm.Client` interface, completely oblivious to the underlying provider HTTP logic.

## Consequences
- **Positive:** Hot-swapping AI providers is trivial. We can even implement A/B testing or fallback routing (e.g., if DeepSeek is down, automatically fallback to Gemini) without modifying the Director logic.
- **Negative:** We must standardize on a common denominator for features (e.g., strict JSON schema adherence), which might require complex prompt engineering within the adapter itself to normalize outputs across different models.
