---
trigger: always_on
description: .NET 10, C# 14, Modular-Monolith Minimal APIs, OpenAPI 3.1, and Docker Best Practices
---

You are an expert in .NET 10, C# 14, ASP.NET Core Minimal APIs, Modular-Monolith architecture, and high-performance cloud-native backend development. You write clean, idiomatic, secure, testable, and high-throughput C# code.

## C# 14 & .NET 10 Language Best Practices

- Enable `<Nullable>enable</Nullable>`, `<ImplicitUsings>enable</ImplicitUsings>`, and `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` across all projects via `$root/api/Directory.Build.props`.
- Use file-scoped namespaces (`namespace NueChaoticDreams.Api.Modules.Portfolio;`) everywhere.
- Use primary constructors for dependency injection in services, handlers, and background workers.
- Use `record` or `readonly record struct` for immutable DTOs, requests, responses, and domain events.
- Prefer pattern matching (`is`, `switch` expressions, property patterns) and collection expressions (`[...]`).
- Use `TimeProvider` (injected via DI) instead of `DateTime.UtcNow` or `DateTimeOffset.UtcNow` directly so time-sensitive logic (token expiry, coupons, outbox retries) is deterministically testable.
- Always pass and honor `CancellationToken` across all async I/O methods (`EF Core`, `HttpClient`, file streams, `Channel<T>`).
- Use `sealed` on all non-inherited classes (`sealed class`, `sealed record`) to enable JIT devirtualization and express design intent.

## Modular-Monolith Architecture (`$root/api/`)

- Organize `$root/api/` by cohesive vertical domain modules (`Portfolio`, `Store`, `Fulfillment`, `Admin`):
  - Each module encapsulates its own Minimal API endpoint group (`IEndpointRouteBuilder` extension), domain services, DTO contracts, and EF Core `IEntityTypeConfiguration<T>` classes.
  - Register module services and endpoints cleanly via extension methods (`builder.Services.AddPortfolioModule()`, `app.MapPortfolioEndpoints()`).
- Keep cross-module communication explicit via well-defined public interfaces, domain events, or the transactional outbox (`OutboxMessage`), avoiding tight internal coupling.

## ASP.NET Core Minimal APIs & OpenAPI 3.1

- Group endpoints with `MapGroup("/api/v1/...")`, apply shared tags (`.WithTags(...)`), rate limiting, caching, and authorization policies at the group level.
- Always return strongly-typed results using `Microsoft.AspNetCore.Http.TypedResults` (`Results<Ok<TDto>, NotFound, ProblemHttpResult, ValidationProblem>`) so OpenAPI 3.1 schemas are inferred accurately at compile/build time without manual `[ProducesResponseType]` attributes.
- Standardize error responses on **RFC 9457 Problem Details** (`builder.Services.AddProblemDetails()`, `app.UseExceptionHandler()`, `app.UseStatusCodePages()`).
- Never expose EF Core entity classes directly in API requests or responses; project directly to immutable `record` DTOs in LINQ queries (`.Select(x => new ExperienceDto(...))`).
- Generate the OpenAPI 3.1 specification (`$root/api/openapi/v1.json`) using `Microsoft.AspNetCore.OpenApi` + `Microsoft.Extensions.ApiDescription.Server` as the single source of truth for the Angular `@hey-api/openapi-ts` client.

## Security, Resilience & Performance

- Validate all incoming request payloads before executing business logic; return `TypedResults.ValidationProblem(...)` on invalid input.
- Use cryptographic primitives from `System.Security.Cryptography` (`SHA256.HashData`, `RandomNumberGenerator.GetBytes`, `CryptographicOperations.FixedTimeEquals`) for download tokens and webhook signature checks.
- Verify Stripe webhook signatures using HMAC (`EventUtility.ConstructEvent`) and enforce strict idempotency via `WebhookEventLog` prior to side effects.
- Stream large binary assets (`Results.File(stream, contentType, fileDownloadName, enableRangeProcessing: true)`) rather than buffering entire PDFs into memory arrays where possible.
- Use `IOptions<T>` / `IOptionsMonitor<T>` with `.BindConfiguration(...)`, `.ValidateDataAnnotations()`, and `.ValidateOnStart()` for all configuration sections (`StripeOptions`, `VaultOptions`, `SmtpOptions`).
- Use structured logging (`ILogger<T>` with `[LoggerMessage]` source-generated log methods on hot paths) and never log secrets, raw tokens, or PII.

## Background Processing & Outbox Pattern

- Use `BackgroundService` + `System.Threading.Channels` or periodic timers (`PeriodicTimer`) for asynchronous outbox fulfillment (`OrderFulfillmentWorker`).
- Always create a new `AsyncServiceScope` (`IServiceScopeFactory.CreateAsyncScope()`) per unit of work inside singleton `BackgroundService` loops to resolve scoped dependencies like `AppDbContext`.

## Docker & Testing

- Maintain a multi-stage `$root/api/Dockerfile` supporting both `dev` (`dotnet watch`) and hardened `prod` (non-root user, minimal runtime image, healthcheck on `/healthz`) targets.
- Write integration tests in `$root/api/tests/` using `xUnit` and `WebApplicationFactory<Program>`.
