# Scout OS (Khasyaraka / Pradigi)

Aplikasi Pramuka digital dengan sistem gamifikasi, pembelajaran interaktif, dan alat survival.

| Stack | Teknologi |
|-------|-----------|
| **Backend** | Go 1.22, Gin, sqlx, golang-migrate |
| **Frontend** | Flutter 3.x, Provider, Riverpod, Dio |
| **Database** | PostgreSQL 15/16 |
| **Cache** | Redis 7 |
| **Auth** | JWT (HMAC-SHA256) + bcrypt + Google Sign-In |
| **AI Engine** | **DeepSeek V4 Flash** (Primary Mission Engine & Socratic AI Mentor) + Gemini |
| **Realtime** | WebSocket (gorilla/websocket / asynq) |
| **Infra** | Docker Compose / Firecracker Sandbox |
| **Deployment** | AWS EC2 |

---

## Struktur Proyek

```
khasyaraka/
│
├── backend/                    # 🚀 Go Backend (Gin Framework)
│   ├── cmd/
│   │   ├── server/main.go         # Entry point server
│   │   ├── seeder/main.go         # Seeder data CLI
│   │   ├── question_builder/      # Builder soal CLI
│   │   └── data_downloader/       # Downloader data CLI
│   │
│   ├── internal/
│   │   ├── config/config.go       # Config via env vars (Viper)
│   │   ├── database/
│   │   │   ├── postgres.go        # Koneksi PostgreSQL (sqlx)
│   │   │   ├── redis.go           # Koneksi Redis
│   │   │   └── migrate.go         # Runner migrasi (golang-migrate)
│   │   ├── middleware/
│   │   │   ├── auth.go            # JWT authentication
│   │   │   ├── cors.go            # CORS
│   │   │   ├── logger.go          # Zerolog request logger
│   │   │   └── recovery.go        # Panic recovery
│   │   ├── httputil/response.go   # Standarisasi response JSON
│   │   ├── router/
│   │   │   ├── router.go          # Router utama (80+ endpoint)
│   │   │   └── health.go          # Health check
│   │   └── modules/               # 17 modul fitur (lihat tabel)
│   │
│   ├── migrations/                # SQL migration files (16 versi)
│   ├── data/                      # Data seed (wilayah Indonesia)
│   ├── go.mod / go.sum
│   ├── Dockerfile
│   └── .env.example
│
├── scout_os_app/               # 📱 Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart              # Entry point
│   │   ├── core/
│   │   │   ├── config/            # API URL, environment
│   │   │   ├── network/           # Dio HTTP client + interceptor JWT
│   │   │   └── services/          # AdMob, analytics, secure storage
│   │   ├── features/              # 14 modul fitur (mirror backend)
│   │   │   ├── auth/              # Login, Register, Google Sign-In
│   │   │   ├── home/              # Dashboard, training path
│   │   │   ├── mission/           # Cyber, SKU, Survival
│   │   │   ├── arena/             # Arena 5v5 & 1v1
│   │   │   ├── ctf/               # Capture The Flag
│   │   │   ├── ai/                # AI Chat
│   │   │   ├── chat/              # Chat wilayah
│   │   │   └── ...
│   │   └── routes/                # Routing (GetX + Material)
│   ├── assets/                    # Gambar, icon, font, audio
│   └── pubspec.yaml
│
├── infra/                       # 🐳 Docker Compose (Full Stack)
│   └── docker-compose.yml         # Postgres 15 + Redis + Go API
│
├── docs/                        # 📚 Dokumentasi
│
├── deploy_aws.sh                # Script deploy ke AWS EC2
└── .gitignore
```

---

## Modul Backend (17 Fitur)

| Modul | Path | Fungsi |
|-------|------|--------|
| **auth** | `internal/modules/auth/` | Register, Login (email & Google), JWT |
| **users** | `internal/modules/users/` | Profil, avatar, streak, XP |
| **training** | `internal/modules/training/` | Course → Section → Unit → Level → Quiz |
| **cyber** | `internal/modules/cyber/` | Materi intel, challenge dekripsi |
| **sandi** | `internal/modules/sandi/` | Enkripsi/dekripsi sandi (Morse, Kotak, DLL) |
| **sku** | `internal/modules/sku/` | Syarat Kecakapan Umum |
| **tkk** | `internal/modules/tkk/` | Tanda Kecakapan Khusus (Purwa/Madya/Utama) |
| **survival** | `internal/modules/survival/` | Tools Pramuka (kompas, GPS, klinometer, dll) |
| **arena** | `internal/modules/arena/` | Battle 5v5 & 1v1 matchmaking |
| **ctf** | `internal/modules/ctf/` | Capture The Flag (defense/attack/patch) |
| **chat** | `internal/modules/chat/` | Chat realtime per wilayah (WebSocket) |
| **ai** | `internal/modules/ai/` | AI Chat (Google Gemini) |
| **token** | `internal/modules/token/` | Token economy (3/hari free, 10/hari pro) |
| **leaderboard** | `internal/modules/leaderboard/` | Peringkat XP (Redis Sorted Set) |
| **hearts** | `internal/modules/hearts/` | Sistem nyawa (5 hearts, regenerasi) |
| **location** | `internal/modules/location/` | Data wilayah Indonesia (prov/kab/kec) |
| **admin** | `internal/modules/admin/` | CRUD admin (users, sections, modules) |
| **subscription** | `internal/modules/subscription/` | Premium subscription |
| **callbacks** | `internal/modules/callbacks/` | AdMob SSV callback |

Setiap modul mengikuti pola yang sama:
```
handler.go   → menerima request HTTP, validasi input
service.go   → logika bisnis, hitung XP,validasi
repository.go → query database (sqlx)
model.go      → struct model
```

---

## Cara Setup Local

### Prasyarat

- Go 1.22+
- Flutter SDK 3.x
- Docker & Docker Compose (opsional, untuk PostgreSQL + Redis)
- PostgreSQL 15+ dan Redis (jika tanpa Docker)

### Opsi A: Setup Cepat dengan Docker

```bash
# 1. Jalankan semua service (Postgres + Redis + API)
cd infra
docker compose up -d

# API sudah jalan di http://localhost:8080
```

### Opsi B: Setup Manual

#### 1. Database & Redis

Jalankan PostgreSQL dan Redis (via Docker atau lokal):

```bash
# Pakai Docker
docker run -d --name pradigi-db \
  -e POSTGRES_USER=scout_admin \
  -e POSTGRES_PASSWORD=scout_password_local \
  -e POSTGRES_DB=scout_os \
  -p 5433:5432 \
  postgres:15-alpine

docker run -d --name pradigi-redis -p 6379:6379 redis:7-alpine
```

#### 2. Backend (Go)

```bash
cd backend

# Buat file .env dari template (jangan commit file .env!)
cp .env.example .env

# Edit .env sesuai kebutuhan
# Minimal: atur DATABASE_URL, JWT_SECRET

# 1. Jalankan server (otomatis menjalankan migrasi database)
go run cmd/server/main.go

# 2. (CUKUP SEKALI) Seed data wilayah Indonesia
# Jalankan ini setelah server pertama kali running
go run cmd/seeder/main.go
```

Server akan jalan di `http://localhost:8080`.

> Proses migrasi database berjalan **otomatis** setiap server start.
> Proses seed data wilayah **dipisahkan** agar tidak membebani server tiap restart.

#### 3. Frontend (Flutter)

```bash
cd scout_os_app

# Install dependencies
flutter pub get

# Jalankan aplikasi (pastikan ada emulator/device)
flutter run
```

> **Note:** URL backend sudah diatur di `lib/core/config/environment.dart`. Untuk development lokal, ubah `apiBaseUrl` ke `http://10.0.2.2:8080/api/v1` (Android emulator) atau `http://localhost:8080/api/v1`.

> **Catatan State Management:**
> - **GetX HANYA** digunakan untuk Routing & Navigation (`Get.to()`, `Get.back()`).
> - **State Management & Dependency Injection** wajib menggunakan **Provider**.
> - Jangan campur aduk keduanya — jangan pakai `Get.put()` untuk controller bisnis, gunakan `ChangeNotifierProvider`.

---

## Environment Variables

Buat file `.env` di `backend/` dengan isi berikut (jangan commit file ini):

```env
PORT=8080
ENVIRONMENT=development

# Database
DATABASE_URL=postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable

# Redis (opsional)
REDIS_URL=redis://localhost:6379/0

# JWT (GANTI dengan secret yang kuat untuk production!)
JWT_SECRET=dev-secret-key-change-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=52560000

# Google OAuth (isi dengan client ID dari Google Cloud Console)
GOOGLE_CLIENT_ID=

# ImageKit (untuk upload avatar)
IMAGEKIT_PRIVATE_KEY=
IMAGEKIT_PUBLIC_KEY=
IMAGEKIT_URL_ENDPOINT=

# Google Gemini AI
GEMINI_API_KEY=
GEMINI_MODEL=gemini-1.5-flash
AI_MAX_OUTPUT_TOKENS=300
AI_TEMPERATURE=0.7
```

> **Keamanan:**
> - File `.env` sudah di-ignore oleh `.gitignore` — tidak akan ikut ter-commit
> - Jangan pernah menyimpan secret di code atau menuliskannya di file yang di-commit
> - Gunakan `.env.example` untuk dokumentasi variable, tanpa nilai rahasia
> - Untuk production, gunakan environment variable di server langsung
>
> **⚠️ PENTING — Gemini API Key:**
> Saat mengembangkan fitur AI di lokal, batasi pengujian chat atau gunakan **mock response**
> di Flutter jika hanya ingin menguji UI. Kesalahan coding frontend (misal infinite loop
> pemanggilan AI) bisa menghabiskan kuota token Gemini API dalam hitungan menit.

---

## Database Migrations

Migrations menggunakan **golang-migrate**. File SQL ada di `backend/migrations/`.

```bash
# Migrasi jalan otomatis saat server start (di main.go)
# Tapi bisa juga dijalankan manual:
go run cmd/server/main.go  # auto migrate di dalamnya
```

Membuat migration baru:

```bash
# Buat file migration baru
# Format: {version}_{title}.up.sql dan .down.sql
# Contoh: 000017_nama_fitur.up.sql
#        000017_nama_fitur.down.sql
```

> Migration menggunakan `file://` source, jadi tinggal taruh file `.sql` di folder `migrations/`.

---

## Alur Request (Dari Aplikasi ke Database)

```
Flutter App
    │  HTTP Request + JWT Bearer Token
    ▼
Gin Router (/api/v1/...)
    │  Recovery → CORS → Logger → Auth (JWT)
    ▼
Handler (validasi input, extract user_id dari token)
    │
    ▼
Service (logika bisnis: validasi, hitung XP, unlock level)
    │
    ▼
Repository (sqlx query ke PostgreSQL)
    │
    ▼
PostgreSQL / Redis
    │
    ▼
Response JSON balik ke Flutter
```

---

## Panduan Kolaborasi untuk Tim Developer

### 1. Git Branching Strategy

```
main (production)
  └── develop (staging)
        ├── feat/nama-fitur     → fitur baru
        ├── fix/nama-bug        → perbaikan bug
        ├── chore/nama-tugas    → refactor, config, dependency
        └── hotfix/nama-fix     → perbaikan darurat production
```

**Aturan:**
- `main` — hanya untuk production. Semua perubahan via pull request.
- `develop` — branch utama untuk development.
- `feat/nama-fitur` — buat dari `develop`, merge balik ke `develop`.
- Jangan commit langsung ke `main` atau `develop`.

### 2. Cara Memulai Fitur Baru

```bash
git checkout develop
git pull origin develop
git checkout -b feat/training-progress-tracking

# ... coding ...

git add .
git commit -m "feat(training): add progress tracking feature"
git push origin feat/training-progress-tracking
```

Buat Pull Request ke branch `develop`, minta review minimal 1 orang.

### 3. Commit Message Convention

```
type(scope): deskripsi singkat

Type: feat, fix, chore, refactor, docs, test, style
Scope: training, auth, cyber, arena, dll
```

Contoh:
- `feat(auth): add Google Sign-In`
- `fix(training): fix XP calculation overflow`
- `chore(deps): upgrade Gin to v1.10`

### 4. Sebelum Push / Pull Request

```bash
# Backend
cd backend
go build ./...              # Pastikan compile tidak error
go vet ./...                # Static analysis
go test ./... -v            # Jalankan test

# Baca ulang kode yang diubah, pastikan tidak ada secret/API key hardcode
grep -r "api_key\|secret\|password" --include="*.go" --include="*.dart"
```

### 5. Pola Coding Backend (Handler → Service → Repository)

```go
// handler.go — hanya handle HTTP
func (h *TrainingHandler) SubmitProgress(c *gin.Context) {
    var req SubmitProgressRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        httputil.Error(c, http.StatusBadRequest, "invalid request")
        return
    }
    userID := c.GetString("user_id")
    result, err := h.service.SubmitProgress(userID, req)
    if err != nil {
        httputil.Error(c, http.StatusInternalServerError, err.Error())
        return
    }
    httputil.Success(c, result)
}

// service.go — logika bisnis
func (s *TrainingService) SubmitProgress(userID string, req SubmitProgressRequest) (*ProgressResult, error) {
    // validasi, hitung XP, update progress
}

// repository.go — akses database
func (r *TrainingRepository) GetLevel(ctx context.Context, levelID string) (*Level, error) {
    var level Level
    err := r.db.GetContext(ctx, &level, "SELECT * FROM training_levels WHERE id = $1", levelID)
    return &level, err
}
```

### 6. Checklist Keamanan untuk Semua Developer

- [ ] Tidak ada `.env` yang ter-commit (sudah di `.gitignore`)
- [ ] Tidak ada API key / password / secret hardcode di kode
- [ ] Tidak ada komentar berisi token/sensitive info
- [ ] Query menggunakan **parameterized query** (`$1`, `$2`), BUKAN concatenation string
- [ ] Input dari user selalu divalidasi (tidak boleh trust langsung)
- [ ] File migration SQL sudah ada `up` dan `down` (agar bisa rollback)

---

## Alur Data Spesifik per Fitur

### Training (Quiz Pramuka)

```
User pilih Course → tampil Sections → pilih Unit → pilih Level → jawab soal
                                                                      │
                                                     ┌────────────────┤
                                                     ▼                ▼
                                                Jawaban Benar    Jawaban Salah
                                                XP +10            Hearts -1
                                                Progress save     Kalau 0 hearts → gagal
                                                                  Regenerasi setelah 30 menit
```

### Arena (5v5 Battle)

```
User create room → kode room dibagikan → tim bergabung → host start
                                                          │
                                                          ▼
                                            Soal dikirim ke semua pemain
                                            Jawab dalam waktu terbatas
                                            Skor diakumulasi per tim
                                            Tim dengan skor tertinggi menang
```

### Cyber (Sandi & Dekripsi)

```
User lihat modul → baca materi intel → buka challenge
                                         │
                                         ▼
                                Lihat encrypted data
                                Tebak sandi (Morse, Kotak, DLL)
                                Decrypt → submit jawaban
                                ✅ Benar → XP + stars
                                ❌ Salah → coba lagi
```

---

## Testing

```bash
# Backend tests
cd backend
go test ./internal/... -v

# Test spesifik
go test ./internal/modules/leaderboard/... -v -run TestCalculateRank

# Frontend tests
cd scout_os_app
flutter test
```

---

## Deployment

Saat ini berjalan di **AWS EC2** (`13.212.174.32:8080`).

```bash
# Deploy manual
./deploy_aws.sh
```

> Script `deploy_aws.sh` menggunakan SSH key dari local path — pastikan file ini
> tidak di-commit dengan key asli, dan tambahkan ke `.gitignore` jika perlu.

---

## Kontrak API (Postman / Endpoint)

Dokumentasi endpoint API tersedia di:

- `docs/API_CONTRACT.md` — Daftar endpoint lengkap
- **[Postman Collection]** — (link akan ditambahkan setelah export)

> Untuk frontend developer: lihat `backend/internal/router/router.go` untuk daftar
> semua endpoint yang tersedia beserta middleware auth-nya.

## Dokumentasi Lainnya

- `docs/architecture/` — Diagram arsitektur
- `docs/migration/` — Panduan migrasi database
- `docs/debugging/` — Tips debugging

---

## Kontribusi

1. Buat branch fitur dari `develop`
2. Ikuti convention commit message
3. Pastikan `go build` dan `go test` sukses
4. Buat Pull Request ke `develop`
5. Minta review dari minimal 1 anggota tim
6. Jangan merge sendiri — tunggu approve
7. **Jangan commit secret/API key apapun ke repository**

---

---

## Strategic Analysis — Competitor Landscape

Berdasarkan riset terhadap kompetitor global dan lokal, berikut posisi Scout OS:

| Platform | Bahasa | Gamified | Cyber Security | AI Agentic | Target Market |
|---|---|---|---|---|---|
| **TryHackMe** | EN | ✅ | ✅ | ❌ | Global (tech) |
| **HackTheBox** | EN | ✅ | ✅ | ❌ | Global (tech) |
| **SiberLab** | ID | ✅ | ✅ | ❌ | Enterprise / CTF |
| **Cyber Academy ID** | ID | ❌ | ✅ | ❌ | Umum |
| **MateriPramuka.com** | ID | ✅ | ❌ | ❌ | Pramuka |
| **Scout OS 🎯** | **ID** | **✅** | **✅** | **✅** | **Pramuka → Umum** |

Scout OS adalah *first-to-market* di persimpangan **Pramuka + Cyber Security + AI Agentic + Gamifikasi Duolingo-like + Bahasa Indonesia**.

---

### SWOT Analysis — Scout OS

#### Strengths (Internal, Positif)

| S | Deskripsi |
|---|-----------|
| S1 | **First-mover** — Belum ada platform yang menggabungkan Pramuka, cyber security, gamifikasi, dan AI native dalam satu produk |
| S2 | **Pasar captive** — Ekosistem Pramuka (~25 juta anggota) sebagai early adopter dengan akses distribusi via Kwarcab/Kwagub |
| S3 | **Tech stack matang** — Go + Flutter + PostgreSQL + Redis + WebSocket, production-ready, sudah terdeploy di AWS |
| S4 | **Fitur lengkap** — Training path, arena 5v5, CTF, sandi, SKU/TKK, token economy, subscription, leaderboard — semua sudah terbangun |
| S5 | **Pramuka relevance** — Sandi (Morse, Kotak, DLL) dan SKU/TKK sudah menjadi konten inti, tidak perlu adaptasi kurikulum dari nol |

#### Weaknesses (Internal, Negatif)

| W | Deskripsi |
|---|-----------|
| W1 | **Konten kosong** — 0 soal terisi dari 1000+ level yang sudah dibuat strukturnya |
| W2 | **No traction** — Brand baru, tidak ada user, tidak ada bukti product-market fit |
| W3 | **AI masih basic** — Fitur AI baru sebatas chat dengan Gemini, belum ada agentic capability (auto-planning, tool use, adaptive learning) |
| W4 | **Resource terbatas** — Tim kecil, fitur banyak tapi belum semuanya matang |
| W5 | **Belum publish** — Aplikasi mobile belum live di Play Store / App Store |

#### Opportunities (External, Positif)

| O | Deskripsi |
|---|-----------|
| O1 | **Blue ocean** — Tidak ada kompetitor langsung di persimpangan Pramuka × Cyber Security × AI × Gamifikasi × Bahasa Indonesia |
| O2 | **Digitalisasi Pramuka** — Pramuka sedang direorganisasi di bawah kepemimpinan baru (2025+), butuh platform digital modern |
| O3 | **Cybersecurity awareness** — Pemerintah Indonesia gencar mendorong literasi digital & keamanan siber (BSSN, CISA) |
| O4 | **AI in education still early** — AI agentic dalam pendidikan MASIH sangat awal secara global (2026 baru panduan, belum ada platform mature), peluang besar untuk lead |
| O5 | **Expansion path jelas** — Start dari Pramuka (captive market) → ekspansi ke siswa SMP/SMA umum → potensi enterprise/CSR dari perusahaan cyber security |
| O6 | **Monetization ganda** — Subscription (Pro), token economy, iklan (AdMob), bisa juga B2B (sekolah/kwarcab beli lisensi) |

#### Threats (External, Negatif)

| T | Deskripsi |
|---|-----------|
| T1 | **Kompetitor global bisa adaptasi** — TryHackMe/HackTheBox sudah punya modal besar, bisa tambah Bahasa Indonesia dan gamifikasi Pramuka |
| T2 | **SiberLab sudah di pasar** — Sudah punya Bahasa Indonesia, konten cyber security, partnership (REDAC7D), tinggal tambah gamifikasi |
| T3 | **Edtech besar masuk** — Ruangguru, Zenius, atau platform edtech lain bisa tambah vertikal cyber security |
| T4 | **Kualitas konten AI** — Soal generated AI berpotensi basi, tidak akurat, atau mudah ditebak pola — butuh human-in-the-loop |
| T5 | **Birokrasi Pramuka** — Adopsi di Kwarcab/Kwagub bisa lambat karena struktur organisasi dan politik internal |
| T6 | **Infrastruktur** — Internet tidak merata di Indonesia, terutama di daerah dengan kontingen Pramuka aktif |

---

### Strategic Implications

1. **Kejar first-mover advantage** — Fokus rilis MVP ke Pramuka ASAP sebelum kompetitor sadar celah ini
2. **Content adalah moat** — Kualitas & kuantitas soal (1000+) harus jadi prioritas #1, dibantu AI generation + kurasi manual
3. **Agentic AI sebagai pembeda jangka panjang** — Duolingo-like adaptive learning dengan AI agent yang bisa auto-plan learning path, generate personalized soal, dan execute code/CTF challenges
4. **Distribution via Pramuka** — Manfaatkan struktur Kwarcab→Kwagub→Gudep untuk distribusi organik
5. **Monitoring kompetitor ketat** — Pantau SiberLab, TryHackMe, dan edtech besar untuk antisipasi pergerakan mereka

---

## Kontribusi

(Existing contribution guide)

---

© 2026 Scout OS Team
