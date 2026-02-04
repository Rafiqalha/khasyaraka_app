# 📁 Khasyaraka Monorepo Structure

## 🏗️ Overview

Monorepo untuk aplikasi **Scout OS (Khasyaraka)** - Platform pembelajaran Pramuka dengan fitur Training, Cyber (Sandi), SKU, dan Survival.

```
khasyaraka/
├── scout_os_app/          # Flutter Mobile App (Frontend)
├── scout_os_backend/      # FastAPI Backend (Backend)
├── docs/                  # Dokumentasi proyek
└── infra/                 # Infrastructure (Docker, dll)
```

---

## 📱 Frontend: `scout_os_app/`

**Technology:** Flutter (Dart)  
**Platform:** Android, iOS, Web

### Struktur Utama

```
scout_os_app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # App configuration
│   │
│   ├── config/                      # Configuration
│   │   └── environment.dart         # API URL, env vars
│   │
│   ├── core/                        # Core utilities
│   │   ├── auth/                    # Local auth service
│   │   ├── network/                 # API client (Dio)
│   │   ├── errors/                  # Error handling
│   │   └── widgets/                 # Shared widgets
│   │
│   ├── features/                    # Feature modules
│   │   ├── auth/                    # Authentication
│   │   │   ├── data/                # Auth repository
│   │   │   ├── logic/               # Auth controller
│   │   │   └── presentation/        # Login, Register pages
│   │   │
│   │   ├── home/                    # Home/Dashboard
│   │   │   └── logic/               # Training controller
│   │   │
│   │   ├── mission/                 # Mission modules
│   │   │   ├── subfeatures/
│   │   │   │   ├── cyber/           # Cyber/Sandi module
│   │   │   │   │   ├── data/        # Cyber models, repository
│   │   │   │   │   ├── logic/       # Cyber controller
│   │   │   │   │   └── presentation/ # Cyber pages, widgets
│   │   │   │   ├── survival/        # Survival tools
│   │   │   │   └── sku/             # SKU module
│   │   │   └── presentation/        # Mission dashboard
│   │   │
│   │   ├── leaderboard/             # Rank/Leaderboard
│   │   │   └── presentation/        # Rank page
│   │   │
│   │   └── profile/                 # User profile
│   │       └── presentation/        # Profile page
│   │
│   └── routes/                       # App routing
│       └── app_routes.dart          # Route definitions
│
├── assets/                          # Assets
│   ├── images/                      # Images, logos
│   ├── icons/                       # Icons
│   └── animations/                  # Animations
│
├── android/                         # Android config
│   └── app/
│       ├── build.gradle.kts         # Build config
│       └── src/main/
│           └── AndroidManifest.xml   # Android manifest
│
├── ios/                             # iOS config
├── pubspec.yaml                     # Flutter dependencies
└── README.md
```

### Key Dependencies

- `provider` - State management
- `dio` - HTTP client
- `google_sign_in` - Google OAuth
- `google_fonts` - Typography
- `flutter_svg` - SVG support
- `shared_preferences` - Local storage

---

## 🔧 Backend: `scout_os_backend/`

**Technology:** FastAPI (Python)  
**Database:** PostgreSQL  
**Cache:** Redis  
**Deployment:** Google Cloud Run

### Struktur Utama

```
scout_os_backend/
├── app/
│   ├── main.py                      # FastAPI app entry
│   │
│   ├── core/                        # Core utilities
│   │   ├── config.py                # Settings, env vars
│   │   ├── security.py              # JWT auth
│   │   └── responses.py             # API response format
│   │
│   ├── db/                          # Database
│   │   ├── session.py               # DB session
│   │   └── base.py                  # Base models
│   │
│   ├── modules/                     # Feature modules
│   │   ├── auth/                    # Authentication
│   │   │   ├── models.py             # User model
│   │   │   ├── schemas.py            # Pydantic schemas
│   │   │   ├── service.py            # Auth business logic
│   │   │   ├── repository.py        # Data access
│   │   │   └── router.py             # API endpoints
│   │   │
│   │   ├── users/                     # User management
│   │   │   ├── models.py
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── router.py
│   │   │
│   │   ├── training/                 # Training module
│   │   │   ├── models.py             # Section, Unit, Level, Question
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── router.py
│   │   │
│   │   ├── cyber/                   # Cyber/Sandi module
│   │   │   ├── models.py             # CyberModule, CyberChallenge
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   ├── repository.py
│   │   │   └── router.py
│   │   │
│   │   ├── sku/                     # SKU module
│   │   │   └── ...
│   │   │
│   │   ├── survival/                 # Survival tools
│   │   │   └── ...
│   │   │
│   │   └── gamification/            # Leaderboard, XP
│   │       ├── models.py
│   │       ├── service.py
│   │       └── router.py
│   │
│   ├── api/                         # API router
│   │   └── router.py                # Main API router
│   │
│   └── data/                        # Seed data
│       ├── cyber_modules.json       # Cyber modules data
│       ├── cyber_challenges.json    # Cyber challenges
│       └── cyber/                   # Module-specific challenges
│
├── alembic/                         # Database migrations
│   ├── versions/                    # Migration files
│   └── env.py
│
├── seed_cyber_data.py               # Cyber data seeder
├── seed_pramuka_data.py             # Training data seeder
├── seed_sku_data.py                 # SKU data seeder
│
├── requirements.txt                 # Python dependencies
├── Dockerfile                       # Docker config
├── alembic.ini                       # Alembic config
└── README.md
```

### Key Dependencies

- `fastapi` - Web framework
- `sqlalchemy` - ORM
- `alembic` - Database migrations
- `asyncpg` - PostgreSQL async driver
- `redis` - Caching
- `google-auth` - Google OAuth verification
- `pydantic` - Data validation

---

## 📚 Documentation: `docs/`

Berisi dokumentasi proyek:
- API contracts
- Architecture docs
- Implementation guides
- Debugging guides
- Migration guides

---

## 🐳 Infrastructure: `infra/`

- `docker-compose.yml` - Local development setup

---

## 🔄 Data Flow

```
Flutter App (scout_os_app)
    ↓ HTTP (Dio)
FastAPI Backend (scout_os_backend)
    ↓ SQLAlchemy
PostgreSQL Database
    ↓ Redis Cache
Cached Data (Leaderboard, XP)
```

---

## 🚀 Key Features

### Frontend (Flutter)
- ✅ Google Sign-In authentication
- ✅ Training paths & lessons
- ✅ Cyber/Sandi cipher challenges
- ✅ SKU (Syarat Kecakapan Umum)
- ✅ Survival tools (Compass, Clinometer, GPS)
- ✅ Leaderboard & XP system
- ✅ User profile

### Backend (FastAPI)
- ✅ JWT authentication
- ✅ Google OAuth verification
- ✅ Training module (Sections, Units, Levels, Questions)
- ✅ Cyber module (Modules, Challenges, Levels)
- ✅ SKU module
- ✅ Survival tools API
- ✅ Leaderboard & XP calculation
- ✅ Redis caching for performance

---

## 📦 Tech Stack Summary

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart) |
| **Backend** | FastAPI (Python) |
| **Database** | PostgreSQL |
| **Cache** | Redis |
| **Auth** | JWT + Google OAuth |
| **Deployment** | Google Cloud Run |
| **State Management** | Provider (Flutter) |
| **HTTP Client** | Dio (Flutter) |
| **ORM** | SQLAlchemy (Python) |
| **Migrations** | Alembic |

---

## 🔐 Environment Variables

### Frontend (`scout_os_app/lib/config/environment.dart`)
- `API_BASE_URL` - Backend API URL

### Backend (`scout_os_backend/app/core/config.py`)
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `SECRET_KEY` - JWT secret key
- `GOOGLE_CLIENT_ID` - Google OAuth client ID

---

## 📝 Important Files

### Frontend
- `lib/main.dart` - App entry point
- `lib/routes/app_routes.dart` - Route definitions
- `pubspec.yaml` - Dependencies

### Backend
- `app/main.py` - FastAPI app
- `app/api/router.py` - Main API router
- `requirements.txt` - Python dependencies
- `alembic.ini` - Migration config

---

## 🎯 Quick Commands

### Frontend
```bash
cd scout_os_app
flutter pub get          # Install dependencies
flutter run              # Run app
flutter build apk        # Build Android APK
```

### Backend
```bash
cd scout_os_backend
pip install -r requirements.txt  # Install dependencies
alembic upgrade head              # Run migrations
python seed_cyber_data.py        # Seed cyber data
uvicorn app.main:app --reload    # Run dev server
```

---

**Last Updated:** February 2026
