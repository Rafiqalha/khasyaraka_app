# Privacy Policy for Khasyaraka

**Terakhir diperbarui: 26 Januari 2025**

Khasyaraka ("kami," "kita," atau "kita") berkomitmen untuk melindungi privasi Anda. Kebijakan Privasi ini menjelaskan bagaimana informasi pribadi Anda dikumpulkan, digunakan, dan diungkapkan oleh Khasyaraka saat Anda menggunakan aplikasi mobile kami ("Aplikasi").

Dengan menggunakan Aplikasi kami, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini.

---

## 1. Informasi yang Kami Kumpulkan

Kami mengumpulkan informasi untuk menyediakan layanan yang lebih baik dan meningkatkan pengalaman belajar Anda di aplikasi Scout OS kami.

### 1.1 Informasi Pribadi

Saat Anda mendaftar atau masuk, kami dapat mengumpulkan:

- **Alamat Email**: Diperlukan untuk pembuatan akun dan autentikasi
- **Nama Lengkap**: Nama tampilan Anda di aplikasi
- **Foto Profil**: Jika Anda masuk dengan Google, kami dapat mengumpulkan URL foto profil Anda
- **Kata Sandi**: Disimpan dengan aman menggunakan hashing standar industri (Argon2). Kami tidak pernah menyimpan kata sandi Anda dalam bentuk teks biasa.

### 1.2 Data Pembelajaran dan Kemajuan

Untuk menyediakan pengalaman belajar yang dipersonalisasi, kami mengumpulkan:

- **Kemajuan Pelatihan**: Status penyelesaian Anda untuk setiap level, bagian, dan unit pelatihan
- **Skor Kuis**: Skor, jawaban benar, dan waktu yang dihabiskan pada setiap kuis
- **Poin Pengalaman (XP)**: Total XP yang diperoleh dari menyelesaikan aktivitas pelatihan
- **Data Streak**: Streak aktivitas harian dan tanggal aktif terakhir
- **Data Pencapaian**: Level hack Anda, jumlah yang didekripsi, dan pencapaian lainnya

### 1.3 Informasi Lokasi

Jika Anda menggunakan fitur GPS Tracker kami (bagian dari alat Survival), kami dapat mengumpulkan:

- **Data Lokasi Real-time**: Koordinat GPS saat ini, arah, kecepatan, dan ketinggian Anda
- **Data Pelacakan**: Jalur pergerakan Anda, jarak yang ditempuh, dan lokasi basecamp
- **Riwayat Lokasi**: Disimpan secara lokal di perangkat Anda untuk fungsionalitas GPS tracker

**Catatan**: Data lokasi hanya digunakan untuk fitur GPS Tracker dan diproses secara lokal di perangkat Anda. Kami tidak mengirimkan data lokasi Anda ke server kami kecuali Anda secara eksplisit menggunakan fitur yang memerlukan berbagi lokasi.

### 1.4 Informasi Perangkat

Kami dapat secara otomatis mengumpulkan informasi tertentu tentang perangkat Anda:

- **Jenis Perangkat**: Model perangkat mobile dan versi sistem operasi
- **Versi Aplikasi**: Versi Khasyaraka yang Anda gunakan
- **Data Teknis**: Pengenal perangkat, alamat IP (untuk permintaan API), dan log crash

Informasi ini membantu kami:
- Memperbaiki bug dan meningkatkan stabilitas aplikasi
- Memberikan dukungan teknis
- Memastikan kompatibilitas di berbagai perangkat

### 1.5 Token Autentikasi

- **Token JWT**: Token autentikasi aman yang disimpan secara lokal di perangkat Anda
- **Token Google OAuth**: Jika Anda masuk dengan Google, token autentikasi dikelola oleh layanan Google

---

## 2. Bagaimana Kami Menggunakan Informasi Anda

Kami menggunakan informasi yang kami kumpulkan untuk:

### 2.1 Menyediakan Layanan Inti

- **Manajemen Akun**: Membuat dan mengelola akun pengguna Anda
- **Autentikasi**: Memverifikasi identitas Anda dan mempertahankan sesi yang aman
- **Pengalaman Belajar**: Melacak kemajuan Anda, menghitung XP, dan membuka konten baru
- **Leaderboard**: Menampilkan peringkat Anda berdasarkan XP dan pencapaian (dengan persetujuan Anda)

### 2.2 Meningkatkan Layanan Kami

- **Analitik**: Menganalisis pola penggunaan untuk meningkatkan fitur aplikasi dan pengalaman pengguna
- **Perbaikan Bug**: Mengidentifikasi dan menyelesaikan masalah teknis
- **Optimasi Performa**: Mengoptimalkan performa aplikasi dan mengurangi crash

### 2.3 Komunikasi

- **Notifikasi Akun**: Mengirimkan pembaruan penting tentang akun atau aplikasi Anda
- **Dukungan**: Menanggapi pertanyaan Anda dan memberikan dukungan pelanggan

---

## 3. Layanan Pihak Ketiga

Kami menggunakan layanan pihak ketiga berikut untuk menyediakan Aplikasi kami:

### 3.1 Layanan Google

- **Google Sign-In**: Untuk autentikasi melalui Google OAuth2
  - **Data yang Dibagikan**: Email, nama, dan foto profil (dengan persetujuan Anda)
  - **Kebijakan Privasi**: [Kebijakan Privasi Google](https://policies.google.com/privacy)

### 3.2 Database dan Infrastruktur

- **PostgreSQL**: Layanan database cloud untuk menyimpan data akun dan kemajuan Anda
- **Redis**: Layanan caching untuk peningkatan performa (leaderboard, data pengguna)

### 3.3 Layanan Pemetaan

- **OpenStreetMap**: Untuk menampilkan peta dalam fitur GPS Tracker
  - **Data yang Dibagikan**: Permintaan tile peta (tanpa data pribadi)
  - **Kebijakan Privasi**: [Kebijakan Privasi OpenStreetMap](https://wiki.openstreetmap.org/wiki/Privacy_Policy)

Pihak ketiga ini hanya memiliki akses ke Informasi Pribadi Anda untuk melakukan tugas tertentu atas nama kami dan berkewajiban untuk tidak mengungkapkan atau menggunakannya untuk tujuan lain.

---

## 4. Penyimpanan dan Keamanan Data

### 4.1 Penyimpanan Data

- **Penyimpanan Server**: Informasi akun, data kemajuan, dan XP Anda disimpan dengan aman di server kami
- **Penyimpanan Lokal**: Token autentikasi dan beberapa preferensi aplikasi disimpan secara lokal di perangkat Anda
- **Retensi Data**: Kami menyimpan data Anda selama akun Anda aktif atau sesuai kebutuhan untuk menyediakan layanan

### 4.2 Tindakan Keamanan

Kami menghargai kepercayaan Anda dalam memberikan Informasi Pribadi kepada kami. Kami menerapkan:

- **Enkripsi**: Kata sandi di-hash menggunakan Argon2, algoritma hashing kata sandi yang aman
- **Autentikasi Aman**: Token JWT dengan kedaluwarsa untuk manajemen sesi yang aman
- **HTTPS**: Semua transmisi data dienkripsi menggunakan HTTPS/TLS
- **Kontrol Akses**: Akses terbatas ke data pribadi berdasarkan kebutuhan

**Penting**: Meskipun kami berusaha menggunakan cara yang dapat diterima secara komersial untuk melindungi data Anda, tidak ada metode transmisi melalui internet atau penyimpanan elektronik yang 100% aman. Kami tidak dapat menjamin keamanan absolut.

---

## 5. Hak dan Pilihan Anda

Anda memiliki hak berikut terkait informasi pribadi Anda:

### 5.1 Akses dan Koreksi

- **Lihat Data Anda**: Anda dapat melihat informasi profil, XP, dan kemajuan Anda dalam Aplikasi
- **Perbarui Informasi**: Anda dapat memperbarui informasi profil Anda melalui pengaturan Aplikasi

### 5.2 Penghapusan Akun

- **Hapus Akun**: Anda dapat meminta penghapusan akun dengan menghubungi kami
- **Penghapusan Data**: Setelah penghapusan akun, kami akan menghapus informasi pribadi Anda, kecuali jika kami diwajibkan untuk menyimpannya oleh hukum

### 5.3 Izin Lokasi

- **Kontrol Akses Lokasi**: Anda dapat memberikan atau mencabut izin lokasi melalui pengaturan perangkat Anda
- **GPS Tracker**: Data lokasi hanya digunakan saat Anda secara aktif menggunakan fitur GPS Tracker

---

## 6. Privasi Anak-Anak

Aplikasi kami dirancang untuk tujuan pendidikan dan dapat digunakan oleh pengguna berbagai usia, termasuk anak-anak di bawah 13 tahun. Kami tidak secara sengaja mengumpulkan informasi pribadi dari anak-anak di bawah 13 tahun tanpa persetujuan orang tua. Jika Anda adalah orang tua atau wali dan percaya anak Anda telah memberikan informasi pribadi kepada kami, silakan hubungi kami segera.

---

## 7. Perubahan pada Kebijakan Privasi ini

Kami dapat memperbarui Kebijakan Privasi kami dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan dengan:

- **Memposting Kebijakan Privasi baru** di Aplikasi
- **Memperbarui tanggal "Terakhir diperbarui"** di bagian atas Kebijakan Privasi ini

Anda disarankan untuk meninjau Kebijakan Privasi ini secara berkala untuk perubahan apa pun. Perubahan berlaku saat diposting.

---

## 8. Hubungi Kami

Jika Anda memiliki pertanyaan, kekhawatiran, atau saran tentang Kebijakan Privasi ini atau praktik data kami, silakan hubungi kami di:

**Email**: [MASUKKAN EMAIL KAMU, CONTOH: support@khasyaraka.com atau privacy@khasyaraka.com]

**Nama Aplikasi**: Khasyaraka  
**Nama Paket**: com.khasyaraka.scout_os

---

## 9. Persetujuan

Dengan menggunakan Aplikasi kami, Anda menyetujui Kebijakan Privasi kami dan menyetujui ketentuannya. Jika Anda tidak setuju dengan kebijakan ini, harap jangan gunakan Aplikasi kami.

---

**Tanggal Efektif**: 26 Januari 2025
