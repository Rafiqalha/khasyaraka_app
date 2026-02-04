# Setup Guide: Google Sign-In Integration for Scout OS

## 🔧 Quick Setup Steps

### **1. Backend - Install Dependencies**
```bash
cd scout_os_backend
pip install -r requirements.txt
```

### **2. Backend - Create Database Migration**
```bash
cd scout_os_backend
alembic revision --autogenerate -m "Add picture_url to users table"
alembic upgrade head
```

This adds the `picture_url` column to store Google profile pictures.

### **3. Frontend - Get Dependencies**
```bash
cd scout_os_app
flutter pub get
```

### **4. Android Setup (if testing on Android)**

#### **Add Google Sign-In Configuration**
Edit `android/app/build.gradle`:
```gradle
dependencies {
    // ... existing dependencies
    // google_sign_in package handles its own dependencies
    implementation 'com.google.android.gms:play-services-auth:21.0.0'
}
```

#### **Update AndroidManifest.xml**
`android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.scout_os_app">
    
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Rest of manifest -->
</manifest>
```

### **5. Get Google Sign-In Credentials**

#### **Option A: For Android Testing**
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable "Google+ API"
4. Go to Credentials → Create OAuth 2.0 Client ID
5. Select "Android" as application type
6. You'll need your app's **SHA-1 fingerprint**:
   ```bash
   # Run this to get SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
7. Add the SHA-1 to Google Cloud Console
8. Download the JSON config and save as `google-services.json`
9. Place in: `android/app/google-services.json`

#### **Option B: For iOS Testing**
1. Same Google Cloud Console steps
2. Select "iOS" as application type
3. Enter your **Bundle ID** (from Xcode project)
4. Download the config file
5. Add to Xcode project:
   - `ios/Runner/GoogleService-Info.plist`

### **6. Configure API Base URL** (Already Done!)
`lib/config/environment.dart` is already set to:
```dart
static const String apiBaseUrl = "http://192.168.1.16:8000/api/v1";
```

Change `192.168.1.16` to your local IP if needed:
```bash
# Get your local IP
ipconfig getifaddr en0  # macOS
hostname -I            # Linux
ipconfig                # Windows (look for "IPv4 Address")
```

### **7. Backend - Ensure Secret Key is Set**
Create/update `.env` in `scout_os_backend/`:
```env
SECRET_KEY=your-super-secret-key-here-use-random-32-chars
ACCESS_TOKEN_EXPIRE_MINUTES=10080
POSTGRES_SERVER=db
POSTGRES_USER=scout_user
POSTGRES_PASSWORD=scout_password
POSTGRES_DB=scout_db
POSTGRES_PORT=5432
```

Or if using docker-compose, environment should already be set.

---

## 📲 Testing on Android Emulator

### **Start Emulator**
```bash
# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd <emulator_name> -gpu host
```

### **Run Flutter App**
```bash
cd scout_os_app

# List connected devices
flutter devices

# Run on emulator
flutter run -d <device_id>
```

### **Test the Flow**
1. App starts → Shows **Onboarding Screen**
2. Click **"GET STARTED"** button
3. Google Sign-In dialog appears
4. Select test Google account
5. Should see loading state
6. Then navigate to **Dashboard** ✅

---

## 🖥️ Testing on Linux Desktop (Fallback)

Since Google Sign-In doesn't natively support Linux desktop, the app will:
1. Show "Platform not supported" dialog
2. Suggest using Android emulator
3. User can tap "OK" to dismiss

**To properly test**, use Android emulator (see above).

---

## 📱 Testing on Physical Android Device

### **Enable Developer Mode**
1. Open Settings → About Phone
2. Tap "Build Number" 7 times
3. Back to Settings → Developer Options
4. Enable "USB Debugging"

### **Connect Device**
```bash
adb devices
```

### **Run App**
```bash
cd scout_os_app
flutter run
```

---

## 🧪 Manual Testing with cURL (Backend Only)

You'll need a real Google ID token. Get one using:
1. [Google OAuth2 Playground](https://developers.google.com/oauthplayground)
2. Or from actual Google Sign-In on device

Then test backend:
```bash
# Replace with real token
GOOGLE_ID_TOKEN="your-real-google-id-token"

curl -X POST http://localhost:8000/api/v1/auth/google \
  -H "Content-Type: application/json" \
  -d "{\"id_token\": \"$GOOGLE_ID_TOKEN\"}"

# Expected Response:
# {
#   "id": 1,
#   "email": "user@gmail.com",
#   "full_name": "User Name",
#   "picture_url": "https://lh3.googleusercontent.com/...",
#   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "token_type": "bearer"
# }
```

---

## 🚀 Full Flow Checklist

- [ ] Backend dependencies installed
- [ ] Database migrated (picture_url added)
- [ ] Frontend dependencies installed (`flutter pub get`)
- [ ] Google Cloud credentials obtained
- [ ] Android app signing configured (SHA-1 in Google Cloud)
- [ ] Backend `.env` has SECRET_KEY set
- [ ] API base URL configured in `environment.dart`
- [ ] Backend running (`python -m uvicorn app.main:app --reload`)
- [ ] Android emulator started
- [ ] Flutter app running (`flutter run`)
- [ ] Test Google Sign-In flow
- [ ] Verify user created in database
- [ ] Verify JWT stored locally
- [ ] Verify token in API requests

---

## 🐛 Common Issues & Fixes

### **Issue: "Google Sign-In not supported on this platform"**
- **Cause**: Running on Linux desktop
- **Fix**: Use Android emulator instead
- **Code**: Platform check is in `onboarding_screen.dart` line ~45

### **Issue: "Invalid Google token" from backend**
- **Cause**: Token is expired or invalid
- **Fix**: Ensure token is < 1 hour old
- **Check**: Decode at [jwt.io](https://jwt.io) and check `exp` timestamp

### **Issue: "Cannot find google_sign_in package"**
- **Cause**: Dependencies not fetched
- **Fix**: 
  ```bash
  flutter clean
  flutter pub get
  ```

### **Issue: "Connection refused" to backend**
- **Cause**: Backend not running or wrong IP
- **Fix**: 
  - Start backend: `python -m uvicorn app.main:app --reload`
  - Check IP: `ipconfig getifaddr en0` (macOS) or `hostname -I` (Linux)
  - Update `environment.dart`

### **Issue: "SHA-1 fingerprint mismatch"**
- **Cause**: Wrong signing key used
- **Fix**: 
  ```bash
  # For debug signing
  keytool -list -v -keystore ~/.android/debug.keystore \
    -alias androiddebugkey -storepass android -keypass android
  ```
  Then add this SHA-1 to Google Cloud Console

### **Issue: Database migration fails**
- **Cause**: Schema already migrated or conflicts
- **Fix**: 
  ```bash
  # Check migration history
  alembic current
  
  # Downgrade if needed
  alembic downgrade -1
  
  # Then upgrade again
  alembic upgrade head
  ```

---

## 📊 Database Check

After first Google Sign-In, verify user was created:

```bash
# Connect to PostgreSQL
psql -h localhost -U scout_user -d scout_db

# Check users table
SELECT id, email, full_name, picture_url, is_active, created_at 
FROM users;
```

You should see:
```
 id │              email               │   full_name    │           picture_url           │ is_active │         created_at
────┼──────────────────────────────────┼────────────────┼──────────────────────────────────┼───────────┼────────────────────────
  1 │ yourname@gmail.com               │ Your Name      │ https://lh3.googleusercontent... │ t         │ 2024-01-17 10:30:00
```

---

## 🔗 Integration with Routes

The screens are ready to integrate. Add to your routing:

```dart
// In app_pages.dart or your routing file
import 'package:scout_os_app/modules/auth/views/onboarding_screen.dart';
import 'package:scout_os_app/modules/auth/views/login_screen.dart';
import 'package:scout_os_app/modules/auth/views/register_screen.dart';

final pages = [
  GetPage(
    name: '/onboarding',
    page: () => const OnboardingScreen(),
  ),
  GetPage(
    name: '/login',
    page: () => const LoginScreen(),
  ),
  GetPage(
    name: '/register',
    page: () => const RegisterScreen(),
  ),
  // ... other pages
];
```

---

## 📚 File Locations for Reference

**Backend Files Modified:**
- `requirements.txt` ← Google Auth libraries
- `app/modules/auth/schemas.py` ← Google schemas
- `app/modules/auth/service.py` ← JWT + Google OAuth logic
- `app/modules/auth/router.py` ← `/auth/google` endpoint
- `app/modules/users/models.py` ← picture_url field

**Frontend Files Created/Modified:**
- `pubspec.yaml` ← New dependencies
- `lib/services/api/auth_service.dart` ← Google Sign-In logic
- `lib/modules/auth/views/onboarding_screen.dart` ← Duolingo UI
- `lib/modules/auth/views/login_screen.dart` ← Login
- `lib/modules/auth/views/register_screen.dart` ← Register
- `lib/modules/auth/logic/auth_controller.dart` ← Enhanced with Google

---

## ✅ You're Ready!

Follow these steps in order, and you'll have a fully functional Google Sign-In system! 🚀

Have questions? Check the implementation file: `GOOGLE_SIGNIN_IMPLEMENTATION.md`
