# ADR-004: Runtime Events Are Immutable

## Status
Accepted

## Context
Pradigi will have multiple AI consumers (Director, Tutor, Reviewer, Career Coach). Each of these models needs to understand the user's past actions to generate accurate, personalized responses. If we constantly overwrite states (e.g., updating a user's `score` in a row), we lose the historical context of *how* they achieved that score.

## Decision
We implement an **Event Store** (`runtime_events`) as the primary historical log. 
Events must be strictly **immutable**. Once an event (e.g., `NODE_COMPLETED`, `CODE_EXECUTED`) is recorded, it can never be updated or deleted. 

All AI generators must derive their "Memory" by replaying or summarizing this immutable event log.

## Consequences
- **Positive:** Unprecedented auditability. If an AI gives bad advice, we can trace exactly what event history it read. Event logs scale perfectly with multiple consumers via an Event Bus.
- **Negative:** The `runtime_events` table will grow very large over time. We will need archival strategies or snapshotting in the future.
