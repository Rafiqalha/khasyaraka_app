# ADR-003: All AI Outputs Must Be JSON

## Status
Accepted

## Context
When interacting with LLMs like DeepSeek, Gemini, or Claude, the models naturally output unstructured Markdown or free-text. Parsing this text in the frontend via Regex or string matching is highly brittle and prone to breaking when the model hallucinates formatting.

## Decision
All prompts sent to the LLM MUST demand strict JSON output. The backend adapters must enforce `response_format: { "type": "json_object" }` (or the equivalent for the specific provider). 

The prompt must explicitly define the exact schema required. If the LLM fails to return valid JSON, the adapter must handle the parsing error gracefully (e.g., by returning a safe fallback struct) and never crash the client.

## Consequences
- **Positive:** Frontend rendering is predictable, type-safe, and stable. Flutter UI components can map directly to the JSON schema.
- **Negative:** LLMs occasionally fail to generate valid JSON if the prompt is too complex. We must write robust fallback logic.
