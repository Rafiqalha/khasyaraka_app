# ADR-005: Redis Is Cache, PostgreSQL Is Source of Truth

## Status
Accepted

## Context
With the introduction of asynchronous AI generation and high-concurrency goals, we need a fast caching layer. Redis is introduced to serve the `HomeResponse` in ~20ms, bypassing the slow 5-10 second LLM generation time.

## Decision
Redis will be used **strictly as a transient Cache and Pub/Sub mechanism**, NEVER as a permanent data store. 
- All critical state (Learning Profiles, Event Logs, Prompt Versions, Telemetry) MUST be persisted in PostgreSQL.
- Cached AI insights (e.g., `director:home:user_id`) must have a finite TTL (e.g., 15 minutes) and can be aggressively evicted or invalidated by the Event Bus.
- Redis Pub/Sub will be used for pushing SSE updates to the client, but the permanent event queue must be backed by PostgreSQL or a persistent queue (like Asynq on top of Redis, which has persistence guarantees).

## Consequences
- **Positive:** We can completely flush Redis at any time during an outage without losing any user progress or critical system state.
- **Negative:** Infrastructure complexity increases; developers must write invalidation logic whenever PostgreSQL state changes.
