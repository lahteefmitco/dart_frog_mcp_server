# Student Management System

Monorepo with three parts:

| Directory | Role |
|-----------|------|
| [`backend/`](backend/) | Dart Frog REST API + PostgreSQL (`/students`) |
| [`mcp_gateway/`](mcp_gateway/) | Dart Frog gateway: proxies `/api/students` to the backend, optional Mistral NL queries at `/api/query`, plus stdio MCP (`bin/mcp_stdio.dart`) |
| [`flutter_app/`](flutter_app/) | Flutter UI (Dio + logging) talking **only** to the gateway |

```mermaid
flowchart LR
  Flutter[Flutter]
  MCP[mcp_gateway]
  API[backend]
  PG[(PostgreSQL)]
  Mistral[Mistral_API]
  Flutter --> MCP
  MCP --> API
  API --> PG
  MCP --> Mistral
```

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.11+
- [Flutter](https://docs.flutter.dev/get-started/install) (for the mobile/desktop app)
- [Docker](https://docs.docker.com/get-docker/) (optional, for PostgreSQL)
- [Dart Frog CLI](https://dart-frog.dev): `dart pub global activate dart_frog_cli`

## 1. Database

Start PostgreSQL (or use your own instance):

```bash
docker compose up -d
```

Apply the schema once:

```bash
# example using psql; adjust host/user if needed
psql "postgresql://postgres:postgres@localhost:5432/students" -f backend/db/schema.sql
```

## 2. Backend API (port 8080)

```bash
cd backend
copy .env.example .env   # Windows — or cp on Unix; set DB_* or DATABASE_URL
dart pub get
dart_frog dev
```

Defaults assume `localhost:5432`, database `students`, user/password `postgres` (see [`backend/.env.example`](backend/.env.example)).

## 3. MCP gateway (port 8081)

```bash
cd mcp_gateway
copy .env.example .env
# Set BACKEND_BASE_URL=http://localhost:8080
# Set MISTRAL_API_KEY for /api/query (optional for CRUD-only)
dart pub get
dart_frog dev --port 8081
```

### Stdio MCP (for Cursor / MCP clients)

From `mcp_gateway/`:

```bash
dart run bin/mcp_stdio.dart
```

Requires `BACKEND_BASE_URL` in `.env` (or environment). Tools: `list_students`, `create_student`.

## 4. Flutter app

The app calls the gateway at **`http://localhost:8081`** by default.

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=GATEWAY_BASE_URL=http://localhost:8081
```

### Android emulator

The emulator cannot use `localhost` for your PC’s services. Use `10.0.2.2` instead:

```bash
flutter run --dart-define=GATEWAY_BASE_URL=http://10.0.2.2:8081
```

## Logging

- **Backend / gateway**: JSON lines on stdout (`component`, `requestId`, `event`, etc.).
- **Flutter**: Dio interceptor logs requests/responses/errors to the debug console (`developer.log` + `debugPrint`).

## API summary

| Service | Endpoint | Notes |
|---------|----------|--------|
| Backend | `GET/POST /students` | CRUD list/create |
| Backend | `GET/PATCH/PUT/DELETE /students/:id` | Single student |
| Backend | `GET /seed_students` | Inserts 100 deterministic sample students (dev convenience) |
| Gateway | `GET/POST /api/students` | Proxied to backend |
| Gateway | `GET/PATCH/PUT/DELETE /api/students/:id` | Proxied |
| Gateway | `POST /api/query` | Body: `{"query":"..."}` — needs `MISTRAL_API_KEY` |

JSON field for class name is **`class`** (mapped to column `student_class` in PostgreSQL).
