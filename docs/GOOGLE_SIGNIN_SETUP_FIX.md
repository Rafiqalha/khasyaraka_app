# Google Sign-In Setup & Fix

**Error**: `Failed to get ID token from Google Sign-In`

## Root Cause

Google Sign-In requires `serverClientId` (OAuth 2.0 Web Client ID) to retrieve ID token. Without it, `googleAuth.idToken` will be `null`.

## Solution

### Step 1: Get Google OAuth Web Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one)
3. Navigate to **APIs & Services** > **Credentials**
4. Find or create **OAuth 2.0 Client ID** of type **"Web application"**
5. Copy the **Client ID** (it looks like: `123456789-abc.apps.googleusercontent.com`)

### Step 2: Configure in Flutter

**Option A: Add to Environment Config (Recommended)**

1. Add to `lib/core/config/environment.dart`:
```dart
class Environment {
  // ... existing code ...
  static const String googleWebClientId = "YOUR_WEB_CLIENT_ID_HERE";
}
```

2. Update `lib/core/network/auth_service.dart`:
```dart
import 'package:scout_os_app/core/config/environment.dart';

AuthService() {
  const String? serverClientId = Environment.googleWebClientId;
  
  _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: serverClientId,
  );
}
```

**Option B: Hardcode (Quick Test Only)**

Update `lib/core/network/auth_service.dart`:
```dart
const String? serverClientId = "YOUR_WEB_CLIENT_ID_HERE";
```

### Step 3: Android Configuration

1. Ensure `google-services.json` is in `android/app/`
2. If missing, download from Firebase Console or Google Cloud Console

### Step 4: iOS Configuration (if needed)

1. Add Google Sign-In URL scheme to `ios/Runner/Info.plist`
2. Configure OAuth client ID in Xcode

## Testing

After configuration:

1. **Test on Android Emulator or Physical Device**
   - Desktop/Web may not work properly
   - Use Android/iOS for full functionality

2. **Verify ID Token**
   - After sign-in, check logs for ID token
   - Should not be null anymore

## Common Issues

### Issue 1: ID Token Still Null
- **Cause**: `serverClientId` not set or incorrect
- **Fix**: Double-check Client ID from Google Cloud Console

### Issue 2: "Sign in failed"
- **Cause**: OAuth consent screen not configured
- **Fix**: Configure OAuth consent screen in Google Cloud Console

### Issue 3: "Platform not supported"
- **Cause**: Running on desktop/web
- **Fix**: Use Android emulator or iOS simulator

## Backend Response Format

Backend returns:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@gmail.com",
    "full_name": "User Name",
    "picture_url": "https://...",
    "access_token": "jwt_token_here",
    "token_type": "bearer"
  },
  "message": "Google sign-in successful",
  "timestamp": "2026-01-20T..."
}
```

Frontend now correctly extracts from `data` field.

## Status

- ✅ Error handling improved
- ✅ Backend response parsing fixed
- ⚠️ `serverClientId` needs to be configured
- ⚠️ `google-services.json` needs to be added (Android)

---

**Next Steps**: Configure `serverClientId` and test on Android device/emulator.
