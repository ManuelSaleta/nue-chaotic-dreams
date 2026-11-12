# Nue Chaotic Dreams

A modern, high-performance, and self-hosted personal portfolio, creative writing gallery, and digital goods platform built with **Angular 22+** and **.NET 10**.

## Architecture & Monorepo Layout

- **`web/`**: Angular 22+ (Zoneless, Signals-first, Standalone components), Angular Material (M3) encapsulated via `@ui`, Storybook (`@storybook/angular`), and single global SCSS tokens.
- **`api/`**: .NET 10 Modular-Monolith Minimal API (`NueChaoticDreams.sln`), Entity Framework Core 10 + PostgreSQL 17 (`Npgsql`), build-time OpenAPI 3.1 specification, and transactional outbox.
- **`compose.yaml`**: Full-stack Docker Compose orchestration (`web`, `api`, `postgres:17-alpine`, `mailpit`).
- **`Makefile`**: Symmetrical developer commands for both Native Local and Docker Compose execution.

## Getting Started

### Prerequisites

- **Node.js**: v22+ (or Node 24 LTS via `.nvmrc`)
- **.NET SDK**: 10.0+
- **Docker & Docker Compose**: v2.20+

### Development Commands

Run `make help` to inspect all available workflow targets:

```bash
make help
```

#### Native Local Execution

```bash
# Start local PostgreSQL 17 and Mailpit
make db

# Start Angular 22+ frontend (http://localhost:4200)
make web

# Start .NET 10 Minimal API natively (http://localhost:5000 / http://localhost:8080)
make api

# Start full stack natively
make dev
```

#### Docker Compose Execution

```bash
# Start full stack in Docker (db + mailpit + web)
make docker-up

# Run frontend container only
make docker-web

# Run PostgreSQL 17 + Mailpit only
make docker-db

# Gracefully stop running containers
make docker-down

# Reset PostgreSQL container and destroy database volume
make docker-db-nuke

# Nuke all project containers, volumes, networks, local images & orphans
make docker-nuke
```

#### Code Quality & Codegen

```bash
# Run unit tests
make test

# Run linters and formatting checks
make lint

# Automatically format code
make fmt

# Build production bundles
make build

# Clean build artifacts and temporary caches
make clean

# Regenerate OpenAPI 3.1 spec and TypeScript client
make openapi-regen
```

## Documentation & Architectural Specs

- [`plan.md`](plan.md): Full-stack execution plan and GitHub issue backlog
- [`design.md`](design.md): Material Design 3 tokens, theme switching, and UI guidelines
- [`AGENTS.md`](AGENTS.md): Coding rules, strict TypeScript, and .NET 10 standards
- [`.agents/rules/`](.agents/rules/): Stack-specific best practices

## License

[MIT license](LICENSE)

## Author

Manuel Saleta
