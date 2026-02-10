# ⚜️ Scout OS (Khasyaraka)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-316192?logo=postgresql)](https://www.postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7.x-red?logo=redis)](https://redis.io)
[![Cloud Run](https://img.shields.io/badge/Google_Cloud_Run-Deployed-4285F4?logo=google-cloud)](https://cloud.google.com/run)

**Scout OS (Khasyaraka)** adalah platform pembelajaran dan manajemen Pramuka modern yang menggabungkan gamifikasi, materi interaktif (Sandi, SKU, TKK), dan alat survive digital dalam satu ekosistem.

Project ini menggunakan arsitektur **Monorepo** yang terdiri dari Mobile App (Flutter) dan Backend API (FastAPI).

---

## 🌟 Fitur Unggulan

### 📱 Mobile App (Frontend)
- **Gamified Learning**: Belajar materi Pramuka dengan sistem XP, Level, dan Leaderboard ala Duolingo.
- **Cyber Center (Sandi)**:
  - Penerjemah Sandi Morse, Rumput, Kotak 1/2, dan Kimia.
  - Keyboard kustom untuk input sandi yang intuitif.
  - Challenge mode untuk menguji kemampuan decoding.
- **Sistem SKU & TKK**:
  - Tracking progress Syarat Kecakapan Umum (SKU) (Siaga, Penggalang, Penegak).
  - **[BARU]** Sistem TKK (Tanda Kecakapan Khusus) dengan level Purwa, Madya, Utama.
  - Verifikasi otomatis untuk submission tugas.
- **Survival Tools**: Kompas digital, Senter Morse, Clinometer, dan GPS Locator.
- **Authentication**: Login aman menggunakan Google Sign-In.
- **Premium UI**: Desain modern (Glassmorphism, Neumorphism) dengan tema "Cyber Scout".

### 🔧 Backend Service (API)
- **Modular Architecture**: Terbagi menjadi modul independen (Auth, Users, Training, Cyber, SKU, TKK, Gamification).
- **High Performance**: Dibangun di atas **FastAPI** dengan **AsyncPG** (Asynchronous PostgreSQL) dan **Redis** caching.
- **TKK Verification Engine**: Logika otomatis untuk penilaian dan kenaikan tingkat TKK.
- **Leaderboard System**: Real-time rank calculation menggunakan Redis Sorted Sets.
- **Cloud Native**: Dioptimalkan untuk deployment di **Google Cloud Run** (Stateless, Dynamic Port Binding).
- **Database**: Menggunakan PostgreSQL dengan Supabase Transaction Pooler untuk skalabilitas tinggi.

---

## 📂 Struktur Monorepo

```bash
khasyaraka/
├── scout_os_app/          # 📱 Flutter Mobile Application
│   ├── lib/               # Source code
│   ├── assets/            # Images, Icons, Animations
│   └── pubspec.yaml       # Flutter dependencies
│
├── scout_os_backend/      # 🔧 FastAPI Backend Service
│   ├── app/               # Application logic
│   ├── alembic/           # Database migrations
│   ├── tests/             # Unit & Integration tests
│   └── Dockerfile         # Cloud Run configuration
│
├── infra/                 # 🏗️ Infrastructure as Code (Terraform/Docker)
└── docs/                  # 📚 Project Documentation
```

---

## 🚀 Panduan Instalasi (Getting Started)

Ikuti langkah-langkah ini untuk menjalankan project di komputer lokal Anda.

### Prasyarat
- **Git**
- **Flutter SDK** (versi 3.x ke atas)
- **Python** (versi 3.11 ke atas)
- **PostgreSQL** (atau akses ke Supabase)
- **Redis** (opsional untuk lokal, wajib untuk fitur leaderboard)

### 1. Clone Repository

```bash
git clone https://github.com/username/khasyaraka.git
cd khasyaraka
```

### 2. Setup Backend (FastAPI)

```bash
cd scout_os_backend

# a. Buat Virtual Environment
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
# venv\Scripts\activate   # Windows

# b. Install Dependencies
pip install -r requirements.txt

# c. Setup Environment Variables
# Buat file .env dari template (jika ada) atau buat baru
touch .env
```

**Isi file `.env`:**
```ini
ENVIRONMENT=development
PROJECT_NAME="Scout OS"
API_V1_STR="/api/v1"

# Database (Ganti dengan kredensial lokal/Supabase Anda)
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/scout_os_db
# Atau individual components:
POSTGRES_SERVER=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=scout_os_db

# Security & Auth
SECRET_KEY=rahasia_super_aman_ganti_ini_nanti
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# Redis (Opsional, fallback ke localhost)
REDIS_HOST=localhost
REDIS_PORT=6379
```

**Jalankan Server:**
```bash
# Menggunakan helper script (Recommended)
./run_local.sh

# Atau manual
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```
Swagger UI akan tersedia di: `http://localhost:8080/docs`

### 3. Setup Frontend (Flutter)

Buka terminal baru dan arahkan ke folder app.

```bash
cd scout_os_app

# a. Get Dependencies
flutter pub get

# b. Konfigurasi API URL (Jika perlu)
# Edit lib/config/environment.dart jika backend berjalan di port/host berbeda
```

**Jalankan Aplikasi:**
```bash
# Pastikan ada device/emulator terkoneksi
flutter run
```

---

## 🛠️ Development Workflow

### Database Migrations (Backend)
Jika Anda mengubah model database di `app/modules/*/models.py`, jalankan perintah berikut:

```bash
# 1. Buat file migrasi baru
alembic revision --autogenerate -m "pesan perubahan"

# 2. Terapkan migrasi ke database
alembic upgrade head
```

### Seeding Data
Untuk mengisi database dengan data awal (Materi Sandi, SKU, dll):

```bash
cd scout_os_backend
python seed_cyber_data.py   # Seed modul Cyber/Sandi
python seed_sku_data.py     # Seed data SKU
```

---

## ☁️ Deployment (Google Cloud Run)

Backend telah dikonfigurasi untuk Google Cloud Run dengan optimasi stateless.

1. **Build Container**:
   ```bash
   gcloud builds submit --tag gcr.io/PROJECT_ID/scout-os-backend
   ```

2. **Deploy**:
   ```bash
   gcloud run deploy scout-os-backend \
     --image gcr.io/PROJECT_ID/scout-os-backend \
     --platform managed \
     --allow-unauthenticated \
     --set-env-vars="ENVIRONMENT=production,DATABASE_URL=...,REDIS_URL=..."
   ```

---

## 🤝 Kontribusi

Silakan buat **Pull Request** untuk fitur baru atau perbaikan bug. Pastikan untuk:
1. Menambahkan test case jika memungkinkan.
2. Memperbarui dokumentasi jika ada perubahan API.
3. Mengikuti coding convention yang ada (PEP8 untuk Python, Effective Dart untuk Flutter).

---

**© 2026 Scout OS Team**
