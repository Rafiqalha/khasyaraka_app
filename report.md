# 📋 Laporan Proyek Khasyaraka (Scout OS)

**Tanggal:** 3 Juli 2026  
**Versi:** 1.0  
**Penulis:** Tim Pengembang Khasyaraka

---

## 1. Ringkasan Proyek

**Khasyaraka (Scout OS)** adalah platform pembelajaran dan manajemen Pramuka modern yang menggabungkan gamifikasi, materi interaktif, dan alat survival digital. Proyek ini menggunakan arsitektur **Monorepo** dengan dua komponen utama:

| Komponen | Teknologi | Deskripsi |
|----------|-----------|-----------|
| **Mobile App** | Flutter (Dart) | Aplikasi Android/iOS untuk end-user |
| **Backend API** | Go (Gin Framework) | REST API server |
| **Database** | PostgreSQL 15 | Penyimpanan data utama |
| **Cache** | Redis | Cache & Leaderboard real-time |
| **Infra** | Docker Compose | Orkestrasi container lokal |

---

## 2. Alur Aplikasi (User Flow)

### 2.1 Alur Pertama Kali (First-Time User)

```
┌─────────────┐    ┌──────────────────┐    ┌──────────────┐    ┌────────────┐    ┌──────────────┐
│ Splash Page │───▶│ Onboarding Page  │───▶│ Login Screen │───▶│ Auto-Login │───▶│  Dashboard   │
│ (loading)   │    │ (Tri Satya &     │    │ (Username &  │    │ check via  │    │ (Main App)   │
│             │    │  Dasa Darma)     │    │  Password)   │    │ JWT Token  │    │              │
└─────────────┘    └──────────────────┘    └──────────────┘    └────────────┘    └──────────────┘
                                                │                                       
                                                ▼                                       
                                          ┌──────────────┐                              
                                          │ Register Page│                              
                                          │ (Nama, User, │                              
                                          │  Password,   │                              
                                          │  Gugus Depan)│                              
                                          └──────────────┘                              
```

**Detail tiap tahap:**

1. **Splash Page** — Menampilkan logo/animasi loading saat aplikasi memuat resources.
2. **Onboarding Page** — Slide interaktif yang menampilkan **Tri Satya** dan **Dasa Darma** Pramuka. Pengguna menggeser dua halaman, lalu menekan tombol "SIAP SEDIA" untuk melanjutkan.
3. **Login Screen** — Pengguna memasukkan **Username** (email) dan **Password**. Terdapat link ke halaman "Daftar" untuk pengguna baru.
4. **Register Page** — Formulir pendaftaran: Nama Lengkap, Username, Password, dan Gugus Depan (opsional).
5. **Auto-Login** — Pada sesi berikutnya, aplikasi mengecek token JWT tersimpan di secure storage. Jika valid, langsung masuk ke Dashboard tanpa login ulang.

### 2.2 Alur Utama Setelah Login (Main App)

Dashboard utama menggunakan **DuoMainScaffold** dengan 4 tab navigasi bawah:

```
┌──────────────────────────────────────────────────────────────────┐
│                        MAIN SCAFFOLD                             │
│                                                                  │
│  ┌────────────┬────────────┬────────────┬────────────┐           │
│  │  Tab 0     │   Tab 1    │   Tab 2    │   Tab 3    │           │
│  │ Training   │  Mission   │ Leaderboard│  Profile   │           │
│  │  Path      │ Dashboard  │  (Rank)    │            │           │
│  └────────────┴────────────┴────────────┴────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                Bottom Navigation Bar                      │    │
│  │  🏕️ Tenda  │  🥾 Hiking  │  🏆 Trophy  │  👧 Profil     │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

| Tab | Halaman | Deskripsi |
|-----|---------|-----------|
| 0 | **Training Path** | Jalur belajar bertingkat ala Duolingo (Section → Unit → Level → Questions) |
| 1 | **Mission Dashboard** | Hub misi: Cyber/Sandi, SKU, dan Survival Tools |
| 2 | **Leaderboard (Rank)** | Papan peringkat real-time berdasarkan XP |
| 3 | **Profile** | Profil pengguna, statistik, streak, dan pengaturan |

### 2.3 Alur Training (Gamified Learning)

```
Training Path Page
  └── Section (misal: "Dasar Kepramukaan")
       └── Unit (misal: "Sejarah Pramuka")
            └── Level 1 (5 soal, min 4 benar, +10 XP)
                 ├── Question (Multiple Choice / Fill Blank / etc.)
                 ├── Submit jawaban → validasi di backend
                 └── Hasil: ✅ Lulus → unlock Level 2, ❌ Gagal → kurangi Heart
```

**Mekanisme Gamifikasi:**
- **XP (Experience Points)**: Didapat dari menyelesaikan level dan challenge.
- **Hearts (Nyawa)**: Maks 5. Berkurang saat gagal level. Bisa diisi ulang via **Rewarded Ads (AdMob)**.
- **Streak**: Hitungan hari berturut-turut pengguna aktif belajar.
- **Leaderboard**: Peringkat real-time menggunakan Redis Sorted Sets.

### 2.4 Alur Mission Dashboard

```
Mission Dashboard
  ├── 🔐 Cyber Center (Sandi Pramuka)
  │    ├── Modul Sandi (Morse, Rumput, Kotak, Kimia, dll.)
  │    ├── Challenge Mode (decode/encode puzzle)
  │    └── Encrypt / Decrypt Tool
  │
  ├── 📜 SKU (Syarat Kecakapan Umum)
  │    ├── Siaga / Penggalang / Penegak
  │    └── Quiz per Poin SKU
  │
  └── 🧭 Survival Tools
       ├── Kompas Digital
       ├── Senter Morse
       ├── Clinometer
       ├── Pedometer
       ├── Leveler
       └── GPS Tracker
```

### 2.5 Alur Autentikasi (Backend)

```
┌─────────────┐         ┌──────────────────┐        ┌──────────────┐
│ Flutter App │────────▶│  Go Backend API  │───────▶│  PostgreSQL  │
│             │  HTTP   │  (Gin Framework) │  SQL   │              │
│ POST /auth/ │         │                  │        │ users table  │
│   login     │         │ bcrypt verify    │        │              │
│   register  │         │ JWT create       │        │              │
└─────────────┘         └──────────────────┘        └──────────────┘
       │                        │
       │                        ▼
       │                 ┌──────────────┐
       │                 │    Redis     │
       │                 │ (Cache,      │
       │                 │  Hearts,     │
       │                 │  Leaderboard)│
       │                 └──────────────┘
       │
       ▼
  JWT Token disimpan
  di Secure Storage
  (flutter_secure_storage)
```

---

## 3. Arsitektur Teknis

### 3.1 Backend (Go + Gin)

**Struktur Modular:**

```
backend/
├── cmd/server/main.go          # Entrypoint
├── internal/
│   ├── config/config.go        # Environment config (Viper)
│   ├── database/               # PostgreSQL & Redis connections
│   ├── middleware/              # Auth JWT, CORS, Logger, Recovery
│   ├── router/router.go        # Semua route definitions
│   └── modules/
│       ├── auth/               # Register, Login, Google Sign-In
│       ├── users/              # Profile, Avatar, GetMe
│       ├── training/           # Sections, Units, Levels, Questions
│       ├── cyber/              # Modul Cyber & Challenge
│       ├── sandi/              # Sandi Pramuka (Encrypt/Decrypt)
│       ├── sku/                # Syarat Kecakapan Umum
│       ├── tkk/                # Tanda Kecakapan Khusus
│       ├── hearts/             # Sistem nyawa (Redis cache-aside)
│       ├── leaderboard/        # Ranking (Redis Sorted Sets)
│       ├── survival/           # Survival tools tracking
│       ├── subscription/       # Premium subscription
│       ├── callbacks/          # AdMob SSV verification
│       └── admin/              # Admin panel API
├── migrations/                 # SQL schema (PostgreSQL)
└── Dockerfile
```

**API Endpoints utama:**

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| POST | `/api/v1/auth/register` | ❌ | Daftar akun baru |
| POST | `/api/v1/auth/login` | ❌ | Login username/password |
| POST | `/api/v1/auth/google` | ❌ | Google Sign-In (nonaktif) |
| GET | `/api/v1/me` | ✅ | Profil user saat ini |
| PATCH | `/api/v1/me/profile` | ✅ | Update profil |
| GET | `/api/v1/me/hearts` | ✅ | Cek jumlah hearts |
| POST | `/api/v1/me/hearts/decrement` | ✅ | Kurangi heart |
| GET | `/api/v1/training/sections` | ❌ | List semua section |
| GET | `/api/v1/training/levels/:id` | ✅ | Ambil soal level |
| POST | `/api/v1/training/levels/:id/submit` | ✅ | Submit jawaban |
| GET | `/api/v1/training/progress` | ✅ | Progress belajar user |
| GET | `/api/v1/cyber/modules` | ❌ | List modul cyber |
| POST | `/api/v1/cyber/challenges/:id/solve` | ✅ | Jawab challenge |
| POST | `/api/v1/sandi/encrypt` | ✅ | Enkripsi teks sandi |
| POST | `/api/v1/sandi/decrypt` | ✅ | Dekripsi teks sandi |
| GET | `/api/v1/sku/points` | ❌ | List poin SKU |
| POST | `/api/v1/sku/points/:id/submit` | ✅ | Submit quiz SKU |
| GET | `/api/v1/leaderboard` | ❌ | Top leaderboard |
| GET | `/api/v1/leaderboard/me` | ✅ | Rank user saat ini |
| GET | `/api/v1/tkk` | ✅ | List badge TKK |
| POST | `/api/v1/tkk/attain` | ✅ | Raih badge TKK |
| GET | `/api/v1/subscription` | ✅ | Status langganan |
| GET | `/api/v1/callbacks/admob` | ❌ | AdMob SSV callback |

### 3.2 Frontend (Flutter)

**State Management:** Provider (ChangeNotifier pattern)

| Controller | Fungsi |
|-----------|--------|
| `AuthController` | Kelola autentikasi, auto-login, logout |
| `LoginController` | Handle login flow (Google & Manual) |
| `TrainingController` | Kelola data training path |
| `SkuController` | Kelola progress SKU |
| `CyberController` | Kelola modul cyber/sandi |
| `SurvivalMasteryController` | Tracking penggunaan survival tools |
| `SurvivalToolsController` | Kelola sensor-based tools |
| `LeaderboardController` | Data leaderboard |
| `ProfileController` | Profil, stats, streak |
| `IntroController` | Onboarding flow |
| `ThemeController` | Light/Dark mode |

### 3.3 Database Schema (PostgreSQL)

**Tabel utama:**

| Tabel | Deskripsi |
|-------|-----------|
| `users` | Data pengguna (email, password hash, XP, streak, hearts) |
| `training_sections` | Bagian besar materi (free/premium tier) |
| `training_units` | Sub-bagian per section |
| `training_levels` | Level per unit (difficulty, XP reward) |
| `training_questions` | Bank soal (type, payload JSON) |
| `user_progress` | Tracking kemajuan per level per user |
| `cyber_modules` | Modul pembelajaran sandi |
| `cyber_challenges` | Soal challenge sandi |
| `sandi_types` | Jenis sandi (Morse, Rumput, Kotak, dll.) |
| `sandi_questions` | Soal latihan per jenis sandi |
| `sku_points` | Poin-poin Syarat Kecakapan Umum |
| `sku_progress` | Progress SKU per user |
| `user_tkk` | Badge TKK yang diraih user (Purwa/Madya/Utama) |
| `survival_mastery` | XP & level per survival tool |
| `subscriptions` | Status langganan premium |

### 3.4 Infrastruktur

**Deployment saat ini:**

| Layer | Service | Lokasi |
|-------|---------|--------|
| Backend API | Go binary | Oracle Cloud VM (`168.110.201.112:8080`) |
| Database | PostgreSQL 15 | Docker container (lokal/cloud) |
| Cache | Redis Alpine | Docker container (lokal/cloud) |
| Mobile App | Flutter APK | Distribusi manual / Play Store |

**Docker Compose** digunakan untuk development lokal dengan 3 service:
- `khasyaraka_db` (PostgreSQL, port 5433)
- `khasyaraka_redis` (Redis, port 6379)
- `khasyaraka_api` (Go backend, port 8080)

---

## 4. Kendala Teknis

### 4.1 🔴 KRITIS: Google Cloud Project Tersuspend

| Item | Detail |
|------|--------|
| **Masalah** | Billing account GCP `0163C7-B98F80-B814AD` bermasalah, project `openclaw-asistenkuliah` di-suspend |
| **Dampak** | Tidak bisa mengakses Google Cloud Console untuk konfigurasi OAuth |
| **Konsekuensi** | Google Sign-In (Error 10 / DEVELOPER_ERROR) tidak bisa diperbaiki |
| **Solusi sementara** | Login manual via Username/Password sudah diimplementasikan. Google Sign-In dinonaktifkan dari UI. |
| **Status** | ⚠️ Workaround aktif |

### 4.2 🔴 KRITIS: Google Sign-In Nonaktif (Error 10)

| Item | Detail |
|------|--------|
| **Masalah** | `PlatformException(sign_in_failed, ApiException: 10)` — SHA-1 fingerprint belum terdaftar di Google Cloud Console |
| **Akar Masalah** | Tidak bisa akses konsol karena GCP tersuspend (4.1) |
| **Solusi sementara** | Migrasi ke login manual. Pengguna lama direset password ke `pradigi05`. |
| **Kode terdampak** | `login_screen.dart`, `login_controller.dart`, `auth_controller.dart` |
| **Status** | ⚠️ Workaround aktif |

### 4.3 🟡 SEDANG: Backend Lama (Python/FastAPI) vs Baru (Go/Gin)

| Item | Detail |
|------|--------|
| **Masalah** | Ada dua backend di repository: `scout_os_backend/` (Python/FastAPI lama) dan `backend/` (Go/Gin baru) |
| **Dampak** | README.md masih merujuk ke FastAPI/Python. Instruksi setup berpotensi membingungkan kontributor. |
| **Rekomendasi** | Update README.md agar hanya merujuk ke backend Go. Hapus atau arsipkan `scout_os_backend/`. |
| **Status** | ⏳ Belum dikerjakan |

### 4.4 🟡 SEDANG: Tidak Ada Unit Test

| Item | Detail |
|------|--------|
| **Masalah** | Tidak ditemukan file test untuk backend Go maupun Flutter app |
| **Dampak** | Regresi bug sulit terdeteksi, refactoring berisiko tinggi |
| **Rekomendasi** | Prioritaskan test untuk modul `auth`, `training`, dan `hearts` |
| **Status** | ⏳ Belum dikerjakan |

### 4.5 🟡 SEDANG: Hardcoded API URL

| Item | Detail |
|------|--------|
| **Masalah** | API base URL di-hardcode di `environment.dart` (`http://168.110.201.112:8080/api/v1`) |
| **Dampak** | Harus rebuild app setiap ganti server. Tidak bisa switch environment tanpa ubah kode. |
| **Rekomendasi** | Gunakan `--dart-define` atau `.env` file untuk konfigurasi per environment |
| **Status** | ⏳ Belum dikerjakan |

### 4.6 🟢 MINOR: Duplicate Import di login_screen.dart

| Item | Detail |
|------|--------|
| **Masalah** | `grass_sos_loader.dart` diimport dua kali (baris 1 & 8 di versi sebelumnya). `flutter_svg` dan `app_colors` diimport tapi mungkin tidak digunakan setelah perubahan login. |
| **Dampak** | Warning saat compile, tidak ada dampak fungsional |
| **Status** | ⏳ Belum diperbaiki |

### 4.7 🟢 MINOR: Tidak Ada Fitur Lupa Password

| Item | Detail |
|------|--------|
| **Masalah** | Setelah migrasi ke login manual, tidak ada mekanisme reset password untuk pengguna |
| **Dampak** | Pengguna yang lupa password tidak bisa masuk kembali tanpa bantuan admin |
| **Rekomendasi** | Implementasi fitur "Lupa Password" via email (memerlukan SMTP service) |
| **Status** | ⏳ Belum dikerjakan |

---

## 5. Kendala Bisnis

### 5.1 🔴 Google Cloud Billing Tersuspend

| Item | Detail |
|------|--------|
| **Masalah** | Akun billing Google Cloud tersuspend, tidak bisa menggunakan layanan GCP apapun |
| **Dampak Bisnis** | Tidak bisa deploy ke Cloud Run. Tidak bisa menggunakan Google OAuth. Kredibilitas infrastruktur berkurang. |
| **Opsi Solusi** | (a) Klik "Fix Now" di appeal page GCP, (b) Buat project GCP baru dengan billing baru, (c) Pindah ke platform lain (Oracle Cloud sudah digunakan) |
| **Status** | ⚠️ Perlu tindakan pengguna |

### 5.2 🟡 Model Monetisasi Belum Tervalidasi

| Item | Detail |
|------|--------|
| **Masalah** | Sistem subscription (`subscription` module) dan AdMob reward ads sudah dibangun di backend, tetapi belum terintegrasi penuh di Flutter app |
| **Komponen tersedia** | Tabel `subscriptions` (tier, payment_ref, provider). AdMob SSV callback verification. Sistem hearts yang bisa diisi via rewarded ads. |
| **Yang belum ada** | Payment gateway integration (Google Play Billing / Midtrans). Fitur premium yang terkunci (training tiers sudah ada field `tier` tapi belum divalidasi). Halaman pricing/upgrade di Flutter. |
| **Status** | ⏳ Belum terintegrasi |

### 5.3 🟡 Distribusi Aplikasi

| Item | Detail |
|------|--------|
| **Masalah** | Belum ada pipeline CI/CD untuk build dan distribusi otomatis |
| **Dampak** | Rilis update manual, proses lambat, rawan human error |
| **Rekomendasi** | Setup GitHub Actions untuk auto-build APK dan deploy backend |
| **Status** | ⏳ Belum dikerjakan |

### 5.4 🟡 Konten Materi Belum Lengkap

| Item | Detail |
|------|--------|
| **Masalah** | Struktur tabel training sudah siap, tetapi belum diketahui seberapa lengkap konten (soal, materi) yang sudah diisi ke database |
| **Dampak** | Pengalaman pengguna bisa terasa kosong jika materi terbatas |
| **Rekomendasi** | Audit isi database, buat seeding script yang lengkap untuk semua section/unit/level |
| **Status** | ⏳ Perlu audit |

### 5.5 🟢 Belum Ada Analytics / Tracking

| Item | Detail |
|------|--------|
| **Masalah** | Tidak ada integrasi analytics (Firebase Analytics, Mixpanel, dsb.) |
| **Dampak** | Tidak bisa mengukur retensi, engagement, atau funnel conversion |
| **Rekomendasi** | Integrasikan Firebase Analytics (gratis) untuk tracking DAU, session, dan event |
| **Status** | ⏳ Belum dikerjakan |

---

## 6. Ringkasan Status

### Fitur yang Sudah Berjalan ✅

- [x] Sistem autentikasi (Register & Login manual via Username/Password)
- [x] Auto-login via JWT token di secure storage
- [x] Onboarding page (Tri Satya & Dasa Darma interaktif)
- [x] Training Path dengan gamifikasi (XP, Hearts, Streak)
- [x] Cyber Center / Sandi Pramuka (Encrypt & Decrypt)
- [x] SKU tracking dan quiz
- [x] TKK badge system (Purwa, Madya, Utama)
- [x] Survival Tools (Kompas, Senter, Clinometer, dll.)
- [x] Leaderboard real-time (Redis)
- [x] Sistem Hearts dengan Redis cache-aside
- [x] AdMob SSV callback verification (backend)
- [x] Admin API endpoints
- [x] Dark/Light theme toggle
- [x] Docker Compose untuk development lokal
- [x] Backend sudah berjalan di Oracle Cloud VM

### Fitur yang Perlu Diselesaikan ⏳

- [ ] Perbaikan Google Sign-In (butuh akses GCP Console)
- [ ] Fitur Lupa Password
- [ ] Integrasi payment gateway untuk subscription premium
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Unit & Integration Tests
- [ ] Analytics tracking
- [ ] Audit kelengkapan konten materi
- [ ] Environment-based API URL configuration
- [ ] Cleanup kode lama (FastAPI backend, dead imports)
- [ ] Update README.md sesuai arsitektur terbaru

---

## 7. Rekomendasi Prioritas

| Prioritas | Aksi | Estimasi |
|-----------|------|----------|
| 🔴 P0 | Selesaikan masalah billing GCP atau buat project baru | 1–2 hari |
| 🔴 P0 | Implementasi fitur Lupa Password | 1 hari |
| 🟡 P1 | Audit & lengkapi konten materi training | 3–5 hari |
| 🟡 P1 | Tambahkan unit test untuk core modules | 2–3 hari |
| 🟡 P1 | Konfigurasi environment-based API URL | 0.5 hari |
| 🟢 P2 | Setup CI/CD (GitHub Actions) | 1 hari |
| 🟢 P2 | Integrasi Firebase Analytics | 0.5 hari |
| 🟢 P2 | Integrasi payment gateway | 3–5 hari |
| 🟢 P2 | Cleanup kode lama & update README | 0.5 hari |

---

*Dokumen ini dibuat secara otomatis berdasarkan analisis kode sumber proyek Khasyaraka per tanggal 3 Juli 2026.*
