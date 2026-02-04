# 📋 Penjelasan Google OAuth Client ID

## 🔑 Dua Jenis Client ID yang Dibutuhkan

Untuk Google Sign-In di Flutter, Anda memerlukan **2 jenis Client ID**:

### 1. **Web Client ID** (untuk `serverClientId` di Flutter)
- **Digunakan di:** `login_page.dart` → `_webClientId`
- **Saat ini:** `890949539640-3gqau7hr96fmdsls1jsv1rukevek0nlb.apps.googleusercontent.com`
- **Fungsi:** Untuk mendapatkan ID token dari Google Sign-In
- **Wajib:** Ya, ini yang digunakan oleh Flutter `google_sign_in` package

### 2. **Android Client ID** (untuk autentikasi Android native)
- **Digunakan di:** Google Cloud Console (untuk verifikasi Android app)
- **Saat ini:** `890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com` (baru)
- **Fungsi:** Untuk verifikasi bahwa aplikasi Android yang mencoba sign-in adalah aplikasi yang benar
- **Wajib:** Ya, untuk menghindari Error 10 (DEVELOPER_ERROR)

---

## ⚠️ PENTING: Jangan Tertukar!

**Untuk Flutter `google_sign_in` package:**
- ✅ `serverClientId` = **Web Client ID** (bukan Android Client ID!)
- ✅ Android Client ID hanya untuk konfigurasi di Google Cloud Console

---

## 🔄 Jika Client ID Baru Adalah Web Client ID

Jika `890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com` adalah **Web Client ID baru**, update kode:

```dart
// Di login_page.dart, line 37
static const String _webClientId = '890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com';
```

---

## 🔄 Jika Client ID Baru Adalah Android Client ID

Jika `890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com` adalah **Android Client ID baru**, **JANGAN** ubah kode Flutter!

- ✅ Android Client ID sudah dikonfigurasi di Google Cloud Console
- ✅ Web Client ID tetap: `890949539640-3gqau7hr96fmdsls1jsv1rukevek0nlb.apps.googleusercontent.com`
- ✅ Tidak perlu mengubah `_webClientId` di `login_page.dart`

---

## ✅ Cara Cek Jenis Client ID

1. Buka [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Klik Client ID yang ingin dicek
3. Lihat **"Application type"**:
   - **"Web application"** = Web Client ID (untuk `serverClientId`)
   - **"Android"** = Android Client ID (untuk konfigurasi Google Cloud Console)

---

## 📝 Konfigurasi Saat Ini

### Di Kode Flutter (`login_page.dart`):
```dart
static const String _webClientId = '890949539640-3gqau7hr96fmdsls1jsv1rukevek0nlb.apps.googleusercontent.com';
```

### Di Google Cloud Console:
- **Web Client ID:** `890949539640-3gqau7hr96fmdsls1jsv1rukevek0nlb.apps.googleusercontent.com`
- **Android Client ID:** `890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com` (baru)
- **Package name:** `com.khasyaraka.scout_os`
- **SHA-1:** `AC:6F:5E:A1:E5:22:53:6E:B5:BC:6D:1E:83:4F:B8:08:C2:A4:45:60`

---

## 🎯 Kesimpulan

**Jika Client ID baru adalah Android Client ID:**
- ✅ Tidak perlu mengubah kode
- ✅ Konfigurasi sudah benar
- ✅ Coba test lagi setelah menunggu propagasi

**Jika Client ID baru adalah Web Client ID:**
- ✅ Update `_webClientId` di `login_page.dart`
- ✅ Rebuild aplikasi
- ✅ Test Google Sign-In
