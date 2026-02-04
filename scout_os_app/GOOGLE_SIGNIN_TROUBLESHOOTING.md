# 🔧 Troubleshooting Google Sign-In Error 10

## ❌ Masalah: Error 10 Masih Terjadi

Meskipun konfigurasi sudah benar di Google Cloud Console, Error 10 masih muncul.

---

## ✅ Solusi Step-by-Step

### **Step 1: Verifikasi Konfigurasi di Google Cloud Console**

Pastikan di Google Cloud Console:

1. **OAuth 2.0 Client ID (Android)** sudah dibuat
2. **Package name:** `com.khasyaraka.scout_os` (sama persis, tanpa spasi)
3. **SHA-1:** `AC:6F:5E:A1:E5:22:53:6E:B5:BC:6D:1E:83:4F:B8:08:C2:A4:45:60`
4. **Status:** Aktif (tidak dihapus atau dinonaktifkan)

**Cek di:** [Google Cloud Console - Credentials](https://console.cloud.google.com/apis/credentials)

---

### **Step 2: Clear Cache & Rebuild Aplikasi**

Error 10 bisa terjadi karena cache lama. Lakukan full rebuild:

```bash
cd /home/rafiq/Projek/khasyaraka/scout_os_app

# 1. Stop aplikasi sepenuhnya
adb shell am force-stop com.khasyaraka.scout_os

# 2. Clear app data (menghapus semua cache dan data)
adb shell pm clear com.khasyaraka.scout_os

# 3. Clean Flutter build
flutter clean

# 4. Get packages lagi
flutter pub get

# 5. Rebuild aplikasi
flutter run
```

---

### **Step 3: Clear Google Play Services Cache**

Google Play Services juga menyimpan cache yang bisa menyebabkan Error 10:

```bash
# Clear Google Play Services cache
adb shell pm clear com.google.android.gms

# Clear Google Account Manager cache
adb shell pm clear com.google.android.gsf.login
```

**Catatan:** Setelah ini, Anda mungkin perlu login ulang ke Google di device.

---

### **Step 4: Verifikasi Keystore yang Digunakan**

Pastikan SHA-1 yang ditambahkan ke Google Cloud Console sesuai dengan keystore yang digunakan untuk build:

**Debug keystore (default):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

**Release keystore (jika build release):**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload | grep SHA1
```

**Pastikan SHA-1 yang ditambahkan ke Google Cloud Console sama dengan SHA-1 dari keystore yang digunakan!**

---

### **Step 5: Tunggu Propagasi Google (PENTING!)**

Setelah menambahkan SHA-1 di Google Cloud Console:
- **Minimum:** 5-10 menit
- **Maksimum:** Beberapa jam (tergantung server Google)
- **Rata-rata:** 15-30 menit

**Jangan langsung test setelah menambahkan SHA-1! Tunggu minimal 10 menit.**

---

### **Step 6: Verifikasi Package Name di build.gradle.kts**

Pastikan package name di `android/app/build.gradle.kts` sama dengan di Google Cloud Console:

```kotlin
defaultConfig {
    applicationId = "com.khasyaraka.scout_os"  // ← Harus sama persis!
}
```

---

### **Step 7: Test dengan Logcat**

Jalankan aplikasi dengan logcat untuk melihat error detail:

```bash
flutter run

# Di terminal lain, jalankan:
adb logcat | grep -i "google\|signin\|oauth"
```

Ini akan menampilkan error detail dari Google Play Services.

---

## 🔍 Checklist Troubleshooting

- [ ] Konfigurasi di Google Cloud Console sudah benar (Package name + SHA-1)
- [ ] Sudah menunggu minimal 10 menit setelah menambahkan SHA-1
- [ ] Sudah clear app data: `adb shell pm clear com.khasyaraka.scout_os`
- [ ] Sudah clear Google Play Services cache
- [ ] Sudah rebuild aplikasi (`flutter clean && flutter run`)
- [ ] SHA-1 yang ditambahkan sesuai dengan keystore yang digunakan
- [ ] Package name di build.gradle.kts sama dengan di Google Cloud Console

---

## 🚨 Jika Masih Error 10

### **Opsi 1: Buat OAuth Client ID Baru**

1. Hapus OAuth Client ID Android yang lama di Google Cloud Console
2. Buat OAuth Client ID Android baru dengan:
   - Package name: `com.khasyaraka.scout_os`
   - SHA-1: `AC:6F:5E:A1:E5:22:53:6E:B5:BC:6D:1E:83:4F:B8:08:C2:A4:45:60`
3. Tunggu 10-15 menit
4. Rebuild aplikasi

### **Opsi 2: Gunakan Release Keystore**

Jika Anda build release APK/AAB, pastikan SHA-1 dari release keystore juga ditambahkan:

```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Tambahkan SHA-1 dari release keystore ke OAuth Client ID Android yang sama (bisa multiple SHA-1).

### **Opsi 3: Verifikasi di Firebase Console**

Jika Anda menggunakan Firebase:
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project `scout-os-dev`
3. Project Settings → Your apps → Android app
4. Pastikan package name dan SHA-1 sudah benar
5. Download `google-services.json` baru jika ada perubahan

---

## 📝 Catatan Penting

1. **Error 10 = DEVELOPER_ERROR** = Konfigurasi tidak cocok
2. **Perubahan di Google Cloud Console butuh waktu untuk terpropagasi**
3. **Cache aplikasi dan Google Play Services bisa menyebabkan masalah**
4. **Package name harus sama persis (case-sensitive)**
5. **SHA-1 harus sesuai dengan keystore yang digunakan untuk build**

---

## ✅ Setelah Semua Langkah

Jika semua langkah sudah dilakukan dan masih error, kemungkinan:
1. Perlu menunggu lebih lama (beberapa jam)
2. Ada masalah dengan Google Cloud Console project
3. Perlu verifikasi ulang semua konfigurasi

**Coba lagi setelah 1-2 jam jika semua langkah sudah dilakukan.**
