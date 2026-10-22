# ADR-0001: Modular Monolith

Status: Proposed

## Decision

Start with a modular monolith for transactional hotel domains.
Run background workers separately and isolate provider adapters.

## Context

The first release spans many domains and external integrations.
Independent microservices at inception would add deployment,
observability, and distributed-transaction complexity.

## Consequences

- Shared deployment for core domain modules.
- Explicit package/module boundaries.
- Background jobs can scale independently.
- Future service extraction remains possible.
- Database ownership and transaction boundaries must be documented.
