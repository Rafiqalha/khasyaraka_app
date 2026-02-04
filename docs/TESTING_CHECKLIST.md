# Scout OS Google Sign-In - Final Checklist & Next Actions

## 📋 Implementation Status: ✅ COMPLETE

All backend and frontend code is implemented and ready for testing!

---

## 🔧 BEFORE YOU START TESTING

### **1. Backend Setup**
- [ ] Install dependencies: `pip install -r requirements.txt`
- [ ] Set `.env` with `SECRET_KEY` (generate random 32-char string)
- [ ] Run database migration: `alembic upgrade head`
- [ ] Start backend: `python -m uvicorn app.main:app --reload`
- [ ] Verify backend runs: `curl http://localhost:8000/`

### **2. Frontend Setup**
- [ ] Run `flutter pub get` in `scout_os_app/`
- [ ] Clean build: `flutter clean`
- [ ] Get packages again: `flutter pub get`

### **3. Google Cloud Console Setup**
- [ ] Create project in [Google Cloud Console](https://console.cloud.google.com)
- [ ] Enable Google+ API
- [ ] Create OAuth 2.0 credentials for Android
- [ ] Get SHA-1 fingerprint: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
- [ ] Add SHA-1 to Google Cloud Console
- [ ] Download `google-services.json`
- [ ] Place in `android/app/google-services.json`

### **4. Update API URL (if needed)**
Edit `lib/config/environment.dart`:
```dart
static const String apiBaseUrl = "http://YOUR_LOCAL_IP:8000/api/v1";
```
Get your IP:
```bash
hostname -I  # Linux
ipconfig getifaddr en0  # macOS
ipconfig  # Windows (look for IPv4 Address)
```

---

## 🧪 TESTING PROCEDURE

### **Phase 1: Backend Verification**
```bash
# 1. Start backend
cd scout_os_backend
python -m uvicorn app.main:app --reload

# 2. Check database connection (should show no errors)
# 3. Verify migration ran: check database for picture_url column
psql -h localhost -U scout_user -d scout_db
SELECT * FROM users;

# 4. Database should be empty at this point
```

### **Phase 2: Frontend Setup**
```bash
# 1. Start Android emulator
emulator -avd <emulator_name> -gpu host &

# 2. Wait for emulator to load (~30 seconds)
# 3. Verify devices are connected
flutter devices

# 4. Run Flutter app
cd scout_os_app
flutter run -d emulator-5554
```

### **Phase 3: Test User Flow**
1. **App starts**
   - Should show `OnboardingScreen`
   - Avatar visible in yellow circle
   - Two buttons visible
   
2. **Click "GET STARTED"**
   - Google Sign-In dialog appears
   - Select or login with test Google account
   - Dialog closes
   - See loading spinner
   
3. **Backend receives request**
   - Check terminal: Should see POST request logged
   - Should see: "Verify Google token..."
   - Should see: "User created" or "User found"
   
4. **Frontend receives token**
   - App navigates to Dashboard (if navigation set up)
   - Or stays on screen if navigation not configured
   
5. **Verify database**
   ```bash
   psql -h localhost -U scout_user -d scout_db
   SELECT * FROM users;
   
   # You should see new user with:
   # - email from your Google account
   # - full_name from Google profile
   # - picture_url from Google profile
   # - is_active = true
   ```

### **Phase 4: Test Returning User**
1. **Close and reopen app**
   - Should still show onboarding (token expires after 7 days)
   - Or implement token check in main.dart to jump to dashboard
   
2. **Click "I ALREADY HAVE AN ACCOUNT"**
   - Should navigate to LoginScreen
   - "Sign in with Google" button available
   - Can sign in with same account
   - Should see same user in database (not duplicated)

### **Phase 5: Test Logout (if implemented)**
1. Navigate to Dashboard (or profile screen)
2. Click Logout
3. Should return to Onboarding
4. SharedPreferences cleared
5. Google sign-out called

---

## ✅ EXPECTED RESULTS

### **Successful First Sign-In**
```
Console Output:
  ✓ Google Sign-In dialog appears
  ✓ User selects Google account
  ✓ Dialog closes
  ✓ Loading spinner shows
  ✓ Backend logs: "POST /api/v1/auth/google"
  ✓ Backend logs: "Verify Google token..."
  ✓ Backend logs: "Creating new user..."
  ✓ Frontend receives: { id, email, full_name, picture_url, access_token }
  ✓ App navigates to Dashboard

Database Check:
  ✓ New user row created
  ✓ email matches Google account
  ✓ full_name matches Google profile
  ✓ picture_url matches Google profile URL
  ✓ is_active = true
  ✓ created_at = current timestamp
```

### **Successful Second Sign-In**
```
Console Output:
  ✓ Same flow as above
  ✓ Backend logs: "User found, returning..."
  ✓ No new user created

Database Check:
  ✓ Only one user record
  ✓ created_at unchanged
  ✓ User count = 1
```

---

## 🐛 TROUBLESHOOTING DURING TESTING

### **Issue: "Invalid Google token" from backend**
**Symptoms:** Backend returns 401 with "Invalid Google token"
**Solution:**
- Check console for exact error message
- Ensure token is fresh (<1 hour old)
- Verify Google Cloud OAuth2 credentials are correct
- Check firewall allows access to Google's servers

### **Issue: "Connection refused" when app hits backend**
**Symptoms:** App shows error after Google sign-in
**Solution:**
- Verify backend is running: `curl http://192.168.1.X:8000/`
- Check IP address in `environment.dart` is correct
- Check firewall isn't blocking port 8000
- Run `adb reverse tcp:8000 tcp:8000` if using emulator

### **Issue: "Platform not supported" dialog on Desktop**
**Symptoms:** Dialog appears when running on Linux
**Expected behavior:** This is normal! Use Android emulator instead.
**Solution:** Don't test on desktop. Use `flutter run -d emulator-5554`

### **Issue: App crashes on launch**
**Symptoms:** Red error screen on app start
**Solution:**
- Check logs: `flutter logs`
- Common cause: Missing dependencies - run `flutter pub get`
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

### **Issue: Google Sign-In button doesn't work on emulator**
**Symptoms:** Button clicked but nothing happens
**Solution:**
- Verify `google-services.json` is in `android/app/`
- Verify SHA-1 in Google Cloud Console matches emulator SHA-1
- Run: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey`
- Restart emulator: `adb emu kill`

### **Issue: Database migration fails**
**Symptoms:** `alembic upgrade head` shows errors
**Solution:**
```bash
# Check current version
alembic current

# Downgrade if needed
alembic downgrade base

# Recreate migration
alembic revision --autogenerate -m "Fix users table"

# Upgrade
alembic upgrade head
```

---

## 🎯 VALIDATION CHECKLIST

After implementing, verify each item:

### **Backend Validation**
- [ ] `requirements.txt` has google-auth libraries
- [ ] `app/modules/auth/schemas.py` has GoogleTokenRequest, GoogleAuthResponse, TokenResponse
- [ ] `app/modules/auth/service.py` has create_access_token(), verify_google_token(), google_sign_in()
- [ ] `app/modules/auth/router.py` has POST /auth/google endpoint
- [ ] `app/modules/users/models.py` has picture_url field
- [ ] `.env` has SECRET_KEY set
- [ ] Backend starts without errors
- [ ] Database migration successful

### **Frontend Validation**
- [ ] `pubspec.yaml` has google_sign_in, flutter_moji, jwt_decoder, shared_preferences
- [ ] `lib/services/api/auth_service.dart` exists with all methods
- [ ] `lib/modules/auth/views/onboarding_screen.dart` shows avatar + buttons
- [ ] `lib/modules/auth/views/login_screen.dart` has Google Sign-In button
- [ ] `lib/modules/auth/views/register_screen.dart` has registration form
- [ ] `lib/modules/auth/logic/auth_controller.dart` has loginWithGoogle()
- [ ] `flutter pub get` completes without errors
- [ ] App runs on emulator without crashes

### **Integration Validation**
- [ ] API endpoint receives sign-in request
- [ ] Backend verifies Google token successfully
- [ ] User is created in database on first sign-in
- [ ] User is found in database on second sign-in
- [ ] JWT token is returned and valid
- [ ] JWT token is stored in SharedPreferences
- [ ] No duplicate users are created
- [ ] User profile picture URL is saved

---

## 📊 DATABASE VERIFICATION

After successful sign-in, run:

```bash
# Connect to database
psql -h localhost -U scout_user -d scout_db -c "SELECT id, email, full_name, picture_url, is_active, created_at FROM users ORDER BY id DESC LIMIT 1;"

# Expected output:
#  id │     email      │ full_name │         picture_url          │ is_active │     created_at
# ────┼────────────────┼───────────┼──────────────────────────────┼───────────┼──────────────────
#   1 │ user@gmail.com │ User Name │ https://lh3.googleusercontent...│     t      │ 2024-01-17...
```

**Verify:**
- [ ] ID is auto-incremented
- [ ] Email is from Google account
- [ ] Full name matches Google profile
- [ ] picture_url starts with https://
- [ ] is_active is true
- [ ] created_at is recent timestamp

---

## 🚀 AFTER TESTING

### **If Everything Works ✅**
1. Congratulations! Your Google Sign-In is working!
2. Integrate screens into your routing system
3. Add navigation guards to check JWT before accessing protected routes
4. Add token refresh logic if needed
5. Deploy to production

### **If Something Breaks ❌**
1. Check the error message carefully
2. Review the troubleshooting section above
3. Check code comments in the implementation
4. Verify all setup steps were completed
5. Make sure endpoints match exactly

---

## 📝 NEXT PHASES

### **Phase 2: Dashboard Integration**
- Add route check: If JWT exists, go to Dashboard; else go to Onboarding
- Add logout button to profile/settings
- Use JWT in all authenticated API calls

### **Phase 3: Error Handling**
- Handle network errors gracefully
- Implement token refresh (if JWT expires)
- Add retry logic for failed requests

### **Phase 4: Analytics**
- Log sign-in events
- Track user registration source (Google vs Email)
- Monitor sign-in success rates

### **Phase 5: Production**
- Configure Google Sign-In for production keys
- Update environment.dart for production API URL
- Set secure storage for production secrets
- Add app signing certificate for Google Play

---

## 📚 DOCUMENTATION REFERENCE

| Document | Purpose |
|----------|---------|
| `IMPLEMENTATION_SUMMARY.md` | Overview of what was built |
| `GOOGLE_SIGNIN_IMPLEMENTATION.md` | Technical details & architecture |
| `GOOGLE_SIGNIN_SETUP_GUIDE.md` | Step-by-step setup instructions |
| This file | Testing & validation checklist |

---

## 💬 QUICK REFERENCE

**Backend Start Command:**
```bash
cd scout_os_backend
python -m uvicorn app.main:app --reload
```

**Frontend Test Command:**
```bash
cd scout_os_app
flutter run -d emulator-5554
```

**Database Check Command:**
```bash
psql -h localhost -U scout_user -d scout_db -c "SELECT * FROM users;"
```

**Get Device ID:**
```bash
flutter devices
```

**Clear Flutter Cache:**
```bash
flutter clean
flutter pub get
```

---

## ✨ YOU'RE READY TO TEST!

Follow the testing procedure above, and your Google Sign-In will be working in minutes!

**Happy testing!** 🚀
