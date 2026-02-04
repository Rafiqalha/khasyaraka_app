# 🔧 Fix Google Sign-In Error 10 (DEVELOPER_ERROR)

## ❌ Error yang Terjadi
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Error Code 10 = DEVELOPER_ERROR**

Ini berarti konfigurasi Google Sign-In di Google Cloud Console belum lengkap untuk Android.

---

## ✅ Solusi: Tambahkan SHA-1 Fingerprint ke Google Cloud Console

### **Step 1: Dapatkan SHA-1 Fingerprint (SUDAH DITEMUKAN)**

SHA-1 fingerprint Anda:
```
AC:6F:5E:A1:E5:22:53:6E:B5:BC:6D:1E:83:4F:B8:08:C2:A4:45:60
```

**Untuk Release Build (jika diperlukan):**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

---

### **Step 2: Tambahkan ke Google Cloud Console**

1. **Buka [Google Cloud Console](https://console.cloud.google.com/)**
2. **Pilih project:** `scout-os-dev` (atau project Anda)
3. **Navigasi ke:** APIs & Services → Credentials
4. **Cari OAuth 2.0 Client ID** dengan nama "Android client" atau buat baru:
   - Klik **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
   - Application type: **"Android"**
   - Name: `Khasyaraka Android` (atau nama lain)
   - Package name: `com.khasyaraka.scout_os`
   - **SHA-1 certificate fingerprint:** `AC:6F:5E:A1:E5:22:53:6E:B5:BC:6D:1E:83:4F:B8:08:C2:A4:45:60`
5. **Klik "CREATE"**

---

### **Step 3: Verifikasi Konfigurasi**

Pastikan di Google Cloud Console Anda memiliki:

1. **OAuth 2.0 Client ID (Web application)**
   - Client ID: `890949539640-3gqau7hr96fmdsls1jsv1rukevek0nlb.apps.googleusercontent.com`
   - ✅ Sudah dikonfigurasi di `login_page.dart`

2. **OAuth 2.0 Client ID (Android)** ← **INI YANG PERLU DITAMBAHKAN**
   - Package name: `com.khasyaraka.scout_os`
   - SHA-1: `AC:6F:5E:A1:E5:22:53:6E:B5:BC:6D:1E:83:4F:B8:08:C2:A4:45:60`

---

### **Step 4: Test Ulang**

1. **Restart aplikasi** (hot restart tidak cukup, perlu full restart)
2. **Coba Google Sign-In lagi**
3. Error seharusnya sudah hilang

---

## 📝 Catatan Penting

### **Package Name**
Pastikan package name di Google Cloud Console sama dengan:
- `com.khasyaraka.scout_os` (dari `android/app/build.gradle.kts`)

### **SHA-1 untuk Release Build**
Jika Anda akan build release APK/AAB, tambahkan juga SHA-1 dari release keystore:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

### **Multiple SHA-1**
Anda bisa menambahkan beberapa SHA-1 (debug + release) ke satu OAuth Client ID Android.

---

## 🔍 Troubleshooting

### Masih Error 10?
1. ✅ Pastikan SHA-1 sudah ditambahkan (tanpa spasi, format: `XX:XX:XX:...`)
2. ✅ Pastikan package name sama persis: `com.khasyaraka.scout_os`
3. ✅ Tunggu 5-10 menit setelah menambahkan SHA-1 (propagasi Google)
4. ✅ Restart aplikasi (bukan hot restart)
5. ✅ Clear app data dan coba lagi

### Error Lain?
- **Error 12500:** User membatalkan sign-in (normal)
- **Error 7:** Network error (periksa koneksi internet)
- **Error 8:** User tidak memilih akun (normal)

---

## ✅ Checklist

- [ ] SHA-1 fingerprint sudah ditambahkan ke Google Cloud Console
- [ ] Package name di Google Cloud Console: `com.khasyaraka.scout_os`
- [ ] OAuth Client ID Android sudah dibuat
- [ ] Sudah menunggu 5-10 menit setelah konfigurasi
- [ ] Sudah restart aplikasi (full restart, bukan hot restart)
- [ ] Google Sign-In berhasil

---

**Setelah menambahkan SHA-1, error seharusnya hilang!** 🎉
