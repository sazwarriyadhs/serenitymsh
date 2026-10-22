# Acceptance Criteria - V.0.0.1

- Authentication and role/property access are enforced.
- OTA offers expose source, timestamp, currency, conditions,
  and an explicit source status.
- Partial provider failures never produce fabricated prices.
- Booking status is confirmed only by the authoritative source.
- Integration events are processed idempotently.
- Financial operations are auditable and permission-controlled.
- AI uses approved knowledge and escalates uncertain requests.
- Review responses require authorized human approval.
- Loyalty redemption is atomic and prevents duplicate spending.
- Dashboard metrics expose data freshness and source limitations.
- Backup restoration and security checks pass before production.
