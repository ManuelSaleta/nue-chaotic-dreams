---
trigger: always_on
description: PostgreSQL 17, Entity Framework Core 10, Npgsql, Indexing, Transactions, and Outbox Best Practices
---

You are an expert in PostgreSQL 17+, Entity Framework Core 10, Npgsql, relational data modeling, query optimization, and transactional reliability. You design schemas and queries that are fast, normalized, safe under concurrency, and maintainable.

## PostgreSQL Schema & Naming Conventions

- Enforce `snake_case` naming across all tables, columns, primary keys, foreign keys, and indexes using `UseSnakeCaseNamingConvention()` (`EFCore.NamingConventions`).
- Use explicit, modular `IEntityTypeConfiguration<T>` classes discovered via `modelBuilder.ApplyConfigurationsFromAssembly(...)`—never clutter `AppDbContext.OnModelCreating` with inline fluent chains or pollute domain entities with data-annotation attributes.
- Always use `timestamptz` (`timestamp with time zone` mapped to `DateTimeOffset` in C#) in UTC for all temporal columns (`created_at`, `paid_at`, `expires_at`, `processed_at`).
- Store all monetary values (`price_cents`, `subtotal_cents`, `discount_cents`, `tax_cents`, `amount_total_cents`) as integer cents (`integer` / `bigint`) alongside an explicit ISO-4217 3-letter `currency` column (`varchar(3)`)—never use `float` or `double` for money.
- Constrain string columns with explicit max lengths (`HasMaxLength(...)`) rather than unbounded `text`, except for rich body fields (`description`, `poem.body`).
- Use PostgreSQL `jsonb` (`HasColumnType("jsonb")`) for structured semi-dynamic payloads (e.g., `outbox_messages.payload_json`, `experiences.contributions`, `experiences.technologies`) with GIN indexes when querying inside JSON.

## Entity Framework Core 10 & Query Performance

- Register `AppDbContext` using `AddDbContextPool<AppDbContext>()` with `UseQueryTrackingBehavior(QueryTrackingBehavior.NoTracking)` as the default. Only enable tracking (`.AsTracking()`) or use `ExecuteUpdateAsync` / `ExecuteDeleteAsync` on explicit write paths.
- Project directly to read DTOs inside the database query (`.Select(e => new ProductDto(...))`) so EF Core selects only the required columns.
- Avoid N+1 queries: use projection or `.AsSplitQuery()` when loading multiple one-to-many collections.
- Use EF Core 10 `UseAsyncSeeding` / `UseSeeding` for deterministic, idempotent reference and catalog data seeding (`resume.json`, `skills.json`, initial digital products).
- Keep all schema changes in version-controlled EF Core migrations (`$root/api/src/NueChaoticDreams.Api/Data/Migrations/`). Never rely on `EnsureCreated()` against relational databases.

## Indexing & Integrity Constraints

- Define explicit unique indexes (`HasIndex(...).IsUnique()`) on natural lookup keys:
  - `digital_products (slug)`
  - `coupons (code)`
  - `invoices (invoice_number)`
  - `orders (stripe_checkout_session_id)`
  - `download_entitlements (token_hash)`
- Add composite or filtered (partial) indexes for high-frequency access patterns:
  - Partial index on `outbox_messages (next_retry_at) WHERE status = 'Pending'` so the background fulfillment worker scans zero completed rows.
  - Index on `digital_products (is_active, sort_order)` for storefront catalog queries.
- Configure explicit foreign key delete behaviors (`DeleteBehavior.Restrict` for financial records like `Order`, `OrderItem`, `Invoice`, and `DownloadEntitlement` so paid history is never accidentally cascade-deleted).

## Concurrency, Idempotency & Transactional Outbox

- **Atomic Entitlement & Coupon Updates**: Increment counters (`download_count`, `redemption_count`) atomically using guarded `ExecuteUpdateAsync` statements (e.g., `Where(e => e.DownloadCount < e.MaxDownloads && e.ExpiresAt > now).ExecuteUpdateAsync(s => s.SetProperty(p => p.DownloadCount, p => p.DownloadCount + 1))`) or optimistic concurrency tokens (`xmin` row version via `.UseXminAsConcurrencyToken()`) to prevent race-condition over-redemptions.
- **Transactional Outbox Pattern**: Whenever an order transitions to `Paid`, persist the `Order` state update, `Invoice`, `DownloadEntitlement`, `WebhookEventLog`, and `OutboxMessage` inside a **single PostgreSQL transaction** (`SaveChangesAsync`).
- **Multi-Instance Safe Polling**: When polling `outbox_messages` from background workers, use `FOR UPDATE SKIP LOCKED` (or atomic status claim updates) so concurrent container instances never process the same email twice.

## Docker & Local Infrastructure

- Run `postgres:17-alpine` (`db` service) in `$root/compose.yaml` with a named persistent volume (`postgres_data`), readiness healthcheck (`pg_isready`), and environment-driven credentials.
- Support `make db` / `make docker-db` to start the database and `make docker-db-nuke` to wipe the `postgres_data` volume and restart a clean PostgreSQL 17 instance for fresh EF Core 10 migrations and seeding.
- Enable Npgsql connection resiliency (`EnableRetryOnFailure`) for transient container/network startups.
