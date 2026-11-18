# Architecture Decision Records

Architecture Decision Records (ADRs) capture decisions that affect multiple features, data ownership, security, persistence, or long-term maintenance.

## Accepted decisions

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-local-persistence-and-cloud-sync.md) | Local persistence and consent-controlled Cloud Sync | Accepted |
| [0002](0002-exercise-media-delivery.md) | Remote exercise media and local catalog cache | Accepted |
| [0003](0003-workout-domain-rules.md) | Keep workout rules independent of widgets | Accepted |

## Creating an ADR

1. Copy TEMPLATE.md.
2. Assign the next sequential number.
3. Describe the context and forces behind the decision.
4. Record the chosen approach and alternatives considered.
5. Explain positive and negative consequences.
6. Record implementation gaps and verification needs.
7. Link the ADR from ARCHITECTURE.md when it affects a shared boundary.

An ADR records a decision and its rationale. It does not prove that every part of the decision is implemented; use the implementation-gap section to keep that distinction explicit.
