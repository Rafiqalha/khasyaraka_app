# Architecture Decision Record: 0001-pivot-to-pradigi

## Context
Khasyaraka (Scout OS) awalnya dibangun sebagai aplikasi Pramuka Digital. Seiring berjalannya waktu, visi produk berkembang menjadi "Pradigi", sebuah AI-native Learning Operating System yang tidak hanya berfokus pada materi kepramukaan, melainkan mengadopsi cakupan pembelajaran yang lebih luas (AI, Cyber, Language, dll).

## Decision
Kita memutuskan untuk melakukan pivot ke Pradigi menggunakan **Strangler Pattern**. 
- Kita tidak akan melakukan *rewrite* total dari awal (karena berisiko tinggi).
- Modul-modul legacy dari Scout OS dibekukan (freeze) dan dipindahkan ke dalam struktur `academies/scout` dan `academies/cyber`. Modul-modul ini tidak akan dihapus karena masih memberikan nilai tambah (value).
- Kontrak API (Endpoint dan Response) **tidak diubah** untuk menjaga kompatibilitas dengan aplikasi klien (Flutter) yang ada.
- Arsitektur baru (Core Engines: Identity, AI, Workspace, Mission) akan dibangun secara bertahap (Phase 2) di dalam direktori `core/`, terpisah dari logika bisnis akademi.

## Consequences
- **Positive:** Mengurangi risiko *downtime*, mempercepat proses transisi tanpa menghentikan *development* fitur yang sedang berjalan, dan memberikan kejelasan batasan antara kode legacy dan sistem baru.
- **Negative:** Struktur internal (*package paths*) berubah, membutuhkan penyesuaian import di berbagai tempat. Codebase mungkin akan sedikit "bengkak" selama masa transisi sampai engine legacy sepenuhnya tergantikan oleh engine baru.
