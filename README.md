# Serenity Hotel Management System

Version: 0.0.1
Status: Initial architecture scaffold

## Architecture

- Customer mobile: Flutter
- Backend API: Go modular monolith
- Background jobs: Go worker
- AI service: Python / FastAPI
- Database: PostgreSQL
- Integration Hub: provider-specific adapters
- Web portals: admin and staff applications

## Core modules

Identity, Properties, PMS, Booking, OTA Price Comparison,
Housekeeping, Maintenance, POS, Finance, Convention & Events,
CRM, AI Concierge, Reputation Guard, Revenue Intelligence,
Loyalty & Rewards, Executive Dashboard.

## Rules

1. Confirm system of record for each business domain.
2. Use authorized provider APIs and feeds.
3. Never store credentials in source code.
4. Use idempotency for financial and booking operations.
5. Record audit events for sensitive actions.
6. Treat external integration capabilities as unverified
   until documentation and access are validated.

## Getting started

Read docs/architecture/SYSTEM-OVERVIEW.md before implementation.
