# Web/API data-access decision

Evento Globolo adopts the
[portfolio four-path ADR](https://github.com/ORESoftware/k8s-cluster/blob/main/docs/architecture/web-api-data-access.md)
for [ORESoftware/k8s-cluster#1399](https://github.com/ORESoftware/k8s-cluster/issues/1399)
and [DEN-3960](https://linear.app/denman/issue/DEN-3960/document-4-web-server-to-api-server-data-access-patterns-across-10).
Choose a path per operation; do not give one process every authority.

## Current boundary and production target

`evgl-mash-web` is currently a foundation scaffold combining Maud pages, HTTP
handlers, an optional database connection used only in health reporting, an
in-memory `Vec<Item>`, and same-process browser WebSocket wake-ups. The
in-memory create route is not authoritative event persistence, the optional
database handle is not an approved P1 reader, and the browser WebSocket is not
P3.

The production split is:

| Operation | Path | Decision |
| --- | --- | --- |
| Render public discovery or tenant-scoped event/venue read models | P1 only after hardening, otherwise P2 | P1 uses distinct read-only roles and allow-listed views with explicit public/tenant visibility. |
| Publish/change events, RSVP, reserve/issue tickets, invite, or check in | P2: stateless HTTP | `evgl-api` owns authorization, inventory concurrency, idempotency, and writes. |
| Receive live inventory, RSVP, or check-in invalidation hints | P3 only if measured | Bounded authenticated subscription; P2 refresh remains authoritative. |
| Import/cross-post events, index discovery, send reminders, or issue notifications | P4: asynchronous queue | Durable idempotent consumers with outbox/commit-before-ack and DLQ handling. |
| Browser `/ws` connection | Browser/web transport | Same-process wake-up hint; not web-server-to-API P3 and never authoritative. |

## Path 1: constrained direct reads

P1 is not enabled by merely setting `DATABASE_URL`. Before adoption, provision
a distinct web-read role with no DML, DDL, ownership, role membership, or
`BYPASSRLS`. Grant only reviewed stable public/catalog and tenant-scoped views;
derive tenant/actor visibility from verified identity; force RLS or equivalent
predicates; and test organizer, attendee, venue, and cross-tenant denial. Bound
the pool and query timeout, cancel on request loss, and never fall back to a
writer credential.

Replica and indexed discovery reads may be stale. Ticket inventory, check-in,
RSVP, invitation, and payment-adjacent flows that need read-after-write or a
lock/serializable decision use P2. Any browser-session store is web-owned and
isolated; it is not permission for product DML through P1.

## Path 2: stateless HTTP

P2 is the default read path and the only path for product commands. `evgl-api`
validates identity, tenant/organizer role, resource ownership, route/schema
version, quotas, inventory state, bounded identifiers, and explicit user intent.
Ticket, RSVP, check-in, invitation, payment-adjacent, and destructive mutations
use one stable idempotency key per logical action and reuse it for transient
retries.

Set connect and total deadlines, cap attempts with jitter, honor `Retry-After`,
and do not retry authentication, authorization, validation, sold-out, expired,
or conflict decisions. Propagate W3C trace context and a request ID. Record route
template, status class, latency, timeout, retry count, inventory contention,
idempotency replay/conflict, and bounded pool pressure. Never log payment
credentials, ticket/check-in secrets, attendee private data, provider tokens,
event body content, or raw request URLs. Saturation rejects bounded work; the
web tier does not queue indefinitely or silently switch to P1.

## Path 3: bounded stateful API connection

P3 is reserved for measured live invalidation needs. Authenticate the web
workload and each tenant/event subscription, cap connections per replica, set
connect/idle/lifetime deadlines, heartbeat, bound both directions, reconnect
with capped jitter, and drain on shutdown. Sequence gaps, buffer overflow, or
disconnect force authoritative P2 resync. Frames do not reserve inventory,
issue tickets, accept RSVP, or complete check-in. The current browser WebSocket
is a separate browser/web path, not evidence that P3 is deployed.

## Path 4: asynchronous NATS or message queue

P4 is the target for imports, cross-posting, search indexing, reminder delivery,
notifications, and other work that outlives an HTTP request. Envelopes are
versioned and contain tenant, actor/service identity, trace context, stable
message/idempotency ID, bounded references, attempt metadata, and expiry—not
payment credentials, ticket secrets, attendee bodies, or provider tokens.
Consumers are durable, idempotent, concurrency-bounded, and ack only after the
result/outbox commit. Configure retry limits, backoff, DLQ policy, graceful
drain, and queue age, redelivery, DLQ, and handler latency metrics. Publication
means accepted, not completed; P2 exposes authoritative status.

## Consistency, failure, and backpressure

- `evgl-api` owns product writes and authoritative inventory/status. The MASH
  process owns presentation and any future isolated browser sessions.
- P1 returns its snapshot; P2 returns committed/accepted API state; P3 is a
  hint; P4 is asynchronous acceptance until the API result changes.
- Database, API, stream, broker, and provider outages fail closed with explicit
  unavailable or pending states; no fallback widens scope or double-books.
- Shutdown stops admission, drains bounded HTTP/P3 work, and leaves unacked P4
  messages eligible for redelivery.

## Contracts, schema, and migrations

Wire formats and generated clients belong in `evgl-interfaces`; reusable domain
behavior belongs in `evgl-libs`; `evgl-api` owns persistence and the product
schema. This scaffold has no reviewed production migration, so deployment is
blocked until the declarative schema and migration history are named in the API
repository, tested for public/tenant isolation and inventory concurrency, and
applied by a one-shot migration identity never mounted into the MASH web or
request-serving API processes.
