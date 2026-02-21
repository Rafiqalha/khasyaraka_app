# SHA-1 Update Guide for Google Sign-In

## 🚨 **CRITICAL: Why SHA-1 Updates Cause Google Sign-In Errors**

When you encounter `status:UNKNOWN` errors in Google Sign-In, it's **ALWAYS** related to SHA-1 certificate mismatches. Here's the complete guide to fix and prevent this issue.

---

## 🔍 **Understanding the Problem**

### **What Happens:**
1. **Google Sign-In** validates your app's SHA-1 certificate fingerprint
2. **Mismatch** between registered SHA-1 and actual app SHA-1 → `status:UNKNOWN`
3. **Result**: Google Sign-In fails with token retrieval errors

### **Root Causes:**
- New debug keystore generated
- Different signing configurations
- Multiple developers with different keystores
- Release vs debug certificate confusion

---

## 🛠️ **Step-by-Step Fix Process**

### **1. Get Current App SHA-1**

#### **For Debug Build:**
```bash
cd android/app
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### **For Release Build:**
```bash
keytool -list -v -keystore app-release-key.keystore -alias release
```

#### **Using Gradle (Recommended):**
```bash
cd android
./gradlew signingReport
```

### **2. Update Google Cloud Console**

1. **Go to**: https://console.cloud.google.com/apis/credentials
2. **Select Project**: `scout-os-dev`
3. **Find OAuth 2.0 Client IDs**
4. **Update SHA-1 Certificate**:
   - Click on your Android Client ID
   - Add new SHA-1 fingerprint
   - **Keep old SHA-1** for other environments

### **3. Update Firebase (If Used)**

1. **Go to**: https://console.firebase.google.com
2. **Select Project**: `scout-os-dev`
3. **Project Settings** → **General**
4. **Add SHA-1** under "Your apps" section

---

## 📱 **Client ID Configuration**

### **IMPORTANT: Android vs Web Client ID**

#### **Android Client ID (for `clientId`):**
```
890949539640-dsg7hbpnslcbhidg4rrh145rom8v6mlr.apps.googleusercontent.com
```
- Used for app identification
- Retrieved from `google-services.json`

#### **Web Client ID (for `serverClientId`):**
```
890949539640-b6pggk05brv780fott32uq1leckbkg80.apps.googleusercontent.com
```
- **CRITICAL** for ID token generation
- Used in `GoogleSignIn(serverClientId: ...)`

### **Correct Implementation:**
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: _androidClientId,        // Android Client ID
  serverClientId: _webClientId,      // Web Client ID (CRITICAL!)
  scopes: ['email', 'profile'],
);
```

---

## 🔄 **Development Workflow Best Practices**

### **1. Team Development Setup**

#### **Share Debug Keystore:**
```bash
# Copy shared debug keystore to team
cp path/to/shared/debug.keystore android/app/debug.keystore
```

#### **Update `gradle.properties`:**
```properties
# Shared debug keystore configuration
MYAPP_RELEASE_STORE_FILE=../keystore/release.keystore
MYAPP_RELEASE_KEY_ALIAS=release
MYAPP_RELEASE_STORE_PASSWORD=your_password
MYAPP_RELEASE_KEY_PASSWORD=your_password
```

### **2. Environment-Specific Setup**

#### **Development Environment:**
- Use shared debug keystore
- Register debug SHA-1 in Google Console

#### **Production Environment:**
- Use production keystore
- Register release SHA-1 in Google Console

### **3. Automated SHA-1 Detection**

#### **Add to `app/build.gradle`:**
```gradle
android {
    ...
    applicationVariants.all { variant ->
        variant.outputs.each { output ->
            def task = project.tasks.create("install${variant.name.capitalize()}", Exec) {
                group = 'build'
                commandLine "${android.sdkDirectory}/platform-tools/adb", "install", "-r", output.outputFile
                doLast {
                    println "SHA-1 for ${variant.name}:"
                    println "keytool -list -v -keystore ${output.outputFile.parentFile}/debug.keystore -alias androiddebugkey -storepass android -keypass android".execute().text
                }
            }
            variant.assemble.dependsOn task
        }
    }
}
```

---

## 🚨 **Troubleshooting Common Issues**

### **Issue 1: `status:UNKNOWN` Error**
```bash
# Solution: Update SHA-1 in Google Console
./gradlew signingReport
# Copy SHA-1 and add to Google Cloud Console
```

### **Issue 2: Multiple SHA-1 Fingerprints**
```bash
# Solution: Keep all valid SHA-1s in Google Console
# Don't remove old SHA-1s, add new ones
```

### **Issue 3: Release Build Fails**
```bash
# Solution: Check release keystore configuration
keytool -list -v -keystore app-release-key.keystore -alias release
# Add release SHA-1 to Google Console
```

### **Issue 4: Different Developer Machines**
```bash
# Solution: Use shared keystore or register each developer's SHA-1
./gradlew signingReport
# Add each SHA-1 to Google Console
```

---

## 📋 **Pre-Deployment Checklist**

### **Before Building:**
- [ ] Run `./gradlew signingReport`
- [ ] Verify SHA-1 matches Google Console
- [ ] Test Google Sign-In on debug build

### **Before Release:**
- [ ] Generate release keystore if not exists
- [ ] Get release SHA-1 fingerprint
- [ ] Add release SHA-1 to Google Console
- [ ] Test release build Google Sign-In

### **After Deployment:**
- [ ] Monitor Google Sign-In success rate
- [ ] Check for `status:UNKNOWN` errors
- [ ] Update SHA-1 if needed

---

## 🔧 **Advanced Configuration**

### **Multiple Environments Setup**

#### **Google Cloud Console Setup:**
1. **Create separate OAuth 2.0 Client IDs**:
   - `scout-os-dev-debug` (development)
   - `scout-os-dev-release` (production)

2. **Register different SHA-1s**:
   - Debug SHA-1 → Debug Client ID
   - Release SHA-1 → Release Client ID

#### **Flutter Configuration:**
```dart
class GoogleSignInConfig {
  static const String _debugClientId = 'debug-client-id';
  static const String _releaseClientId = 'release-client-id';
  static const String _webClientId = 'web-client-id';
  
  static String get clientId {
    return kDebugMode ? _debugClientId : _releaseClientId;
  }
  
  static GoogleSignIn get googleSignIn => GoogleSignIn(
    clientId: clientId,
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );
}
```

---

## 🎯 **Quick Fix Summary**

### **When Google Sign-In Fails:**
1. **Get SHA-1**: `./gradlew signingReport`
2. **Update Google Console**: Add SHA-1 to OAuth Client ID
3. **Verify Client IDs**: Android vs Web Client ID usage
4. **Test Again**: Clean build and test

### **Prevention:**
1. **Use shared keystore** for team development
2. **Register all SHA-1s** in Google Console
3. **Document SHA-1 changes** in version control
4. **Automate SHA-1 detection** in CI/CD

---

## 📞 **Emergency Contacts**

### **Google Cloud Console:**
- https://console.cloud.google.com/apis/credentials
- Project: `scout-os-dev`

### **Firebase Console:**
- https://console.firebase.google.com
- Project: `scout-os-dev`

### **Useful Commands:**
```bash
# Get all SHA-1 fingerprints
./gradlew signingReport

# Clean build
flutter clean && flutter pub get

# Test on specific device
flutter run -d <device_id>
```

---

## 🔄 **Version Control Integration**

### **Add to `.gitignore`:**
```
# Keystore files (never commit!)
*.keystore
*.jks
keystore.properties
```

### **Add to `README.md`:**
```markdown
## Google Sign-In Setup
1. Get SHA-1: `./gradlew signingReport`
2. Add to Google Console: https://console.cloud.google.com/apis/credentials
3. Update Client IDs in `lib/core/services/auth_service.dart`
```

---

**⚠️ Remember**: SHA-1 issues are **ALWAYS** configuration problems, never code issues. The fix is always in Google Cloud Console, not in your Flutter code!
