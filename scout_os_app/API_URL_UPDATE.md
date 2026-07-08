# ✅ API URL Updated ke Production

**Date:** 2026-01-26  
**Status:** ✅ **COMPLETED**

---

## 📝 Changes Made

### **File Updated:**

**`lib/core/config/environment.dart`**

**Before:**
```dart
static const String apiBaseUrl = "http://192.168.1.18:8000/api/v1";
```

**After:**
```dart
static const String apiBaseUrl = "https://pradigi-890949539640.asia-southeast2.run.app/api/v1";
```

---

### **Comments Updated:**

**`lib/features/home/data/datasources/training_service.dart`**

**Before:**
```dart
/// Base URL: Environment.apiBaseUrl (e.g., http://192.168.1.18:8000/api/v1)
```

**After:**
```dart
/// Base URL: Environment.apiBaseUrl (Production: https://pradigi-890949539640.asia-southeast2.run.app/api/v1)
```

---

## ✅ Verification

- ✅ **No trailing slash** - URL ends with `/api/v1` (no extra `/`)
- ✅ **HTTPS enabled** - Using `https://` for production
- ✅ **Correct path** - Includes `/api/v1` prefix as required by backend
- ✅ **All references updated** - Main config and comments updated

---

## 🔍 Files Using apiBaseUrl

All files use `Environment.apiBaseUrl` (no hardcoded URLs):

- ✅ `lib/core/network/api_dio_provider.dart`
- ✅ `lib/core/network/api_client.dart`
- ✅ `lib/features/home/data/datasources/training_service.dart`
- ✅ `lib/features/home/data/services/training_api_service.dart`
- ✅ `lib/features/leaderboard/services/leaderboard_repository.dart`
- ✅ `lib/features/mission/subfeatures/sku/services/sku_repository.dart`
- ✅ `lib/features/home/logic/training_controller_v2.dart`

**No changes needed** - All use `Environment.apiBaseUrl` dynamically.

---

## 🚀 Next Steps

1. **Test API Connection:**
   ```bash
   # Test dari Flutter app
   flutter run
   ```

2. **Verify Endpoints:**
   - Login/Register
   - Training sections
   - Leaderboard
   - All API calls should use production URL

3. **For Local Development:**
   If you need to switch back to localhost, update `environment.dart`:
   ```dart
   static const String apiBaseUrl = "http://192.168.1.18:8000/api/v1";
   ```

---

## 📋 Production URL Details

- **Base URL:** `https://pradigi-890949539640.asia-southeast2.run.app`
- **API Prefix:** `/api/v1`
- **Full API URL:** `https://pradigi-890949539640.asia-southeast2.run.app/api/v1`
- **Region:** `asia-southeast2` (Jakarta)

---

**Status:** ✅ **API URL updated to production**
