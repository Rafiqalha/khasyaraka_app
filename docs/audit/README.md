# KHASYARAKA (Scout OS)

KHASYARAKA is a Scout-focused learning and progression platform inspired by Duolingo-style learning paths,
built with a clear separation between Freemium and Premium features.

This repository follows strict architectural and coding rules.
Any contribution or AI-assisted code MUST comply with the rules below.

---

## 1. PROJECT CONTEXT

### Architecture
- **Type:** Monorepo
- **Frontend:** Flutter (Mobile App) → `scout_os_app/`
- **Backend:** Python FastAPI (Async) → `scout_os_backend/`
- **Database:** PostgreSQL
- **Cache:** Redis
- **Authentication:** Custom JWT (Access + Refresh)
- **Deployment:** Railway
- **Containerization:** Docker & Docker Compose

---

## 2. GENERAL ENGINEERING RULES (GLOBAL)

### Language
- **Code comments:** English
- **User-facing explanations & UI text:** Indonesian

### Repository Awareness (CRITICAL)
- Always verify working directory:
  - `scout_os_backend/` → Backend logic, migrations, API
  - `scout_os_app/` → Flutter UI & state
- NEVER mix frontend and backend logic.

### Environment Variables
- ❌ NEVER hardcode secrets
- ✅ Python: `os.getenv()`
- ✅ Flutter: `flutter_dotenv`
- `.env` files must NOT be committed

---

## 3. BACKEND RULES (FastAPI)

### Tech Stack
- FastAPI (Async)
- SQLAlchemy Async
- Pydantic v2
- Alembic (Mandatory)
- Redis (Caching & session control)

### Folder Structure (Required)
```

app/
├── api/
│    ├── routers/
│    └── dependencies/
├── models/
├── schemas/
├── services/
├── repositories/
├── core/
│    ├── config.py
│    ├── security.py
│    └── redis.py
└── main.py

````

### Database Workflow (ABSOLUTE RULE)
1. Define models in `app/models/`
2. Run:
   ```bash
   alembic revision --autogenerate -m "message"
````

3. Run:

   ```bash
   alembic upgrade head
   ```
4. ❌ NEVER:

   * Create tables manually
   * Use GUI tools (DBeaver, pgAdmin)
   * Use raw SQL for schema creation

### API Design Rules

* Routers must be THIN
* Business logic goes in `services/`
* DB access only via `repositories/`
* Use dependency injection (`Depends`)

### Caching Rules

Redis must be used for:

* Leaderboards
* XP & Streak calculations
* Rate limiting
* Temporary tokens

❌ Redis must NOT be used as primary storage

---

## 4. FRONTEND RULES (Flutter)

### State Management

* Preferred: Riverpod
* Allowed: Provider
* ❌ No global mutable state

### Networking

* Use **Dio**
* All API calls go through `services/`
* ❌ NEVER call API directly from Widgets

### Model Synchronization (CRITICAL)

* Flutter `.fromJson()` MUST exactly match:

  * Pydantic schemas
  * Field names
  * Nullable rules

Mismatch = BUG

### UI Philosophy

* Free Content → Duolingo-style curved path
* SKU → Linear & structured path
* SKK → List / grid (non-linear)
* Navigation & CyberScout → Tool-based UI (no gamification)

---

## 5. FREEMIUM VS PREMIUM RULES

### Free Tier

* General scouting material
* Basic quizzes
* Linear progression
* Limited retries

### Premium Tier

* SKU official paths
* SKK skill tracking
* Offline navigation
* CyberScout module

❌ Premium is NOT “unlock all”
✅ Premium introduces NEW SYSTEMS

---

## 6. DEPLOYMENT & SCALING

### Platform

* Railway (Backend, PostgreSQL, Redis)

### Performance Rules

* Minimize database hits
* Prefer Redis reads
* Async everywhere

### Docker

* Backend MUST be Docker-compatible
* No OS-specific assumptions

---

## 7. AI ASSISTANCE POLICY (IMPORTANT)

Any AI-generated code MUST:

* Follow this README
* Respect folder boundaries
* Respect database workflow
* Never invent structure or dependencies

Violations must be corrected immediately.

````

---

# 🧠 `.cursorrules` — KHASYARAKA (UNTUK CODEX)

```txt
You are an AI engineer working on the KHASYARAKA (Scout OS) monorepo.

GLOBAL RULES:
- This is a monorepo.
- Always identify whether you are operating in:
  - scout_os_backend (FastAPI)
  - scout_os_app (Flutter)
- Never mix frontend and backend responsibilities.
- Code comments must be in English.
- User-facing explanations must be in Indonesian.
- Never hardcode secrets. Always use environment variables.

BACKEND (FastAPI) RULES:
- Use FastAPI (Async) only.
- ORM: SQLAlchemy Async.
- Validation: Pydantic v2.
- Database schema changes MUST follow Alembic workflow.
- Never create or modify tables using raw SQL or external tools.
- Routers must remain thin.
- Business logic belongs in services.
- Database access belongs in repositories.
- Redis is mandatory for high-read data and rate-limiting.
- PostgreSQL is the single source of truth.

FRONTEND (Flutter) RULES:
- State management: Riverpod preferred.
- Networking: Dio only.
- API calls must go through services layer.
- Widgets must not contain business logic.
- Flutter models must match backend schemas exactly.

UI & PRODUCT RULES:
- Free content uses Duolingo-style curved paths.
- SKU uses linear, structured progression.
- SKK uses non-linear list or grid.
- Navigation and CyberScout are tool-based, not gamified.

DEPLOYMENT RULES:
- Backend must be Docker-compatible.
- Target deployment platform is Railway.
- Optimize for scalability and performance.

AI BEHAVIOR:
- Do not invent architecture.
- Do not ignore existing patterns.
- If unsure, ask before generating code.
````

