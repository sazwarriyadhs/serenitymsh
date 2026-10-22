# Serenity HMS - System Overview

## Architectural style

Begin with a modular monolith for transactional domain logic.
Keep workers and provider connectors behind explicit interfaces.
Split services only when operational or scaling needs justify it.

## Core boundaries

- Identity and access
- Property and room master data
- PMS and reservations
- OTA rate comparison
- Integration Hub
- Guest services and AI Concierge
- Housekeeping and maintenance
- POS and finance
- Convention and events
- Reputation and revenue intelligence
- Loyalty
- Reporting and executive dashboard

## System-of-record policy

Document one authoritative source for each data domain.
External PMS and booking systems may remain authoritative.
Do not write to an external provider unless the integration
is authorized and the required capability is confirmed.

## Integration lifecycle

Receive -> Authenticate -> Validate -> Deduplicate ->
Normalize -> Process -> Audit -> Retry or dead-letter.

## Security

Apply least privilege, property-level authorization,
secret management, audit logging, data minimization,
retention policies, and tested backups.

## Initial non-goals

This scaffold does not implement real vendor integrations,
payment processing, production authentication, or live OTA
pricing. These require separate implementation and testing.
