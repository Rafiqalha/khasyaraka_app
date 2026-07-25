# ADR-001: Runtime Session is the Single Source of Truth

## Status
Accepted

## Context
Pradigi is transitioning to an AI-native Learning Operating System. We have complex orchestration involving multiple AI models (Director, Tutor, Coach). If AI models are allowed to hold or dictate the core state of a user's progress (e.g., what node they are on, how many competencies they have mastered), the system becomes prone to hallucination, inconsistency, and difficult debugging.

## Decision
We mandate that the **Runtime Manager (Go code backed by PostgreSQL)** is the absolute Single Source of Truth (SSOT) for application state. 
- The Current Node
- Progress Percentage
- Knowledge Graph Data
- Mastered/Missing Competencies

All of the above must be derived deterministically by the Runtime Manager. 
No AI output is permitted to directly mutate these state variables unless explicitly authorized via a highly constrained, validated event payload.

## Consequences
- **Positive:** System state is highly predictable, deterministic, and safe from AI hallucinations. The frontend can render the core OS interface even if all AI providers are down.
- **Negative:** Requires strict discipline when designing new AI features; developers cannot use the LLM as a shortcut for complex state routing.
