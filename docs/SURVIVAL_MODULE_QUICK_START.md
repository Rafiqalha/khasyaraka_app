# ⚡ Survival Module Refactoring - Quick Start Guide

## What Changed?

**Survival went from a level-based game to an offline utility toolkit.**

### OLD ❌
- Levels, XP, progression
- API calls to backend
- Can't use without internet
- Database tables

### NEW ✅
- 3 instant-access tools
- 100% offline
- Direct device sensors
- No progression/XP

---

## For Backend Developers

### 1. Update Router
Replace `scout_os_backend/app/modules/survival/router.py` with this:

```python
from fastapi import APIRouter, Depends
from app.core.security import get_current_user

router = APIRouter()

@router.get("/tools/config")
async def get_tools_config(current_user: dict = Depends(get_current_user)):
    """Get static tool config - backend is optional now"""
    return {
        "tools": {
            "compass": {
                "name": "🧭 Kompas",
                "description": "Real-time magnetic heading",
                "available": True,
            },
            "clinometer": {
                "name": "📐 Klinometer",
                "description": "Angle/Height Measure",
                "available": True,
            },
            "gps": {
                "name": "📍 GPS Tracker",
                "description": "Coordinate Finder",
                "available": True,
            },
        },
        "message": "All survival tools are 100% offline!",
    }

@router.get("/health")
async def health_check():
    """Health check - backend is optional"""
    return {"status": "ok", "module": "survival"}
```

### 2. Remove Old Endpoints
Delete these methods:
- `get_user_mastery()` (old `/mastery`)
- `record_tool_action()` (old `/action`)

### 3. (Optional) Database Cleanup
Old tables you can drop (or keep for history):
- `survival_mastery` - no longer used

---

## For Flutter Developers

### 1. Add Dependencies
```bash
cd scout_os_app
flutter pub add sensors_plus geolocator
flutter pub get
```

Or manual in `pubspec.yaml`:
```yaml
dependencies:
  sensors_plus: ^1.4.0
  geolocator: ^9.0.0
```

### 2. Copy New Files
From the implementation, copy to your project:

```
lib/features/mission/subfeatures/survival/
├── logic/
│   ├── survival_tools_controller.dart         [NEW]
│   └── survival_mastery_controller.dart       [DELETE]
├── presentation/pages/
│   ├── survival_dashboard_page.dart           [NEW]
│   ├── compass_tool_page.dart                 [NEW]
│   ├── clinometer_tool_page.dart              [NEW]
│   ├── gps_tracker_tool_page.dart             [NEW]
│   └── survival_tools_page.dart               [REPLACE]
└── data/
    ├── survival_repository_new.dart           [NEW]
    └── survival_mastery_model.dart            [DELETE]
```

### 3. Update Routes
In `lib/routes/app_routes.dart`:
```dart
class AppRoutes {
  // Survival
  static const survivalDashboard = '/survival/dashboard';
  static const survivalCompass = '/survival/compass';
  static const survivalClinometer = '/survival/clinometer';
  static const survivalGpsTracker = '/survival/gps';
  // ... other routes
}
```

### 4. Update Main App
In `lib/main.dart` or `lib/app.dart`:
```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(
      create: (_) => SurvivalToolsController(),
    ),
  ],
  child: MyApp(),
)
```

### 5. Update Navigation
Change any links to Survival from old page to new dashboard:
```dart
// OLD
Navigator.pushNamed(context, AppRoutes.survivalPage);

// NEW
Navigator.pushNamed(context, AppRoutes.survivalDashboard);
```

### 6. Fix Permissions
**Android** - `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BODY_SENSORS" />
```

**iOS** - `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Need location for GPS Tracker</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Need location for GPS Tracker</string>
</key>NSBonjourServiceType</key>
<array></array>
</dict>
```

---

## Quick Test

### 1. Run the App
```bash
flutter run
```

### 2. Navigate to Survival
Tap on the Survival menu → Should see 3-card grid instantly (no loading spinner)

### 3. Test Each Tool
- **Compass:** Opens, needle should move as you rotate phone
- **Clinometer:** Opens, angles should change as you tilt
- **GPS:** Opens, should request permission, then show coordinates

### 4. Test Offline
- Disable WiFi and cellular
- All 3 tools should still work perfectly

---

## Before/After Code Comparison

### OLD: Making API Calls
```dart
// ❌ OLD - Required internet
class SurvivalMasteryController extends ChangeNotifier {
  Future<void> loadMastery() async {
    final response = await _repository.fetchMastery();  // API call
    // Wait for network...
  }
}
```

### NEW: Direct Sensors
```dart
// ✅ NEW - 100% offline
class SurvivalToolsController extends ChangeNotifier {
  Future<void> initializeSensors() async {
    _initializeCompass();        // Direct magnetometer
    _initializeClinometer();     // Direct accelerometer
    await _initializeGps();      // Direct GPS
  }
}
```

---

## Debugging Tips

### Compass Not Working
```dart
// Test compass stream
compassEvents.listen((event) {
  print('Compass heading: ${event.heading}°');
  print('Magnetic field: ${event.magneticField} μT');
});
```

### GPS Stuck
```dart
// Check permission
final permission = await Geolocator.checkPermission();
print('Location permission: $permission');

// Get single position
final position = await Geolocator.getCurrentPosition();
print('Position: ${position.latitude}, ${position.longitude}');
```

### Accelerometer Data
```dart
// Test accel stream
accelerometerEvents.listen((event) {
  print('X: ${event.x}, Y: ${event.y}, Z: ${event.z}');
});
```

---

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Compass always returns 0° | Check device has magnetometer; move away from metal |
| GPS never acquires signal | Ensure location permission granted; go outside with clear sky |
| Accelerometer reading: NaN | Device may need calibration; place flat on table |
| App crashes on GPS init | Check `geolocator` version compatibility |
| Dark theme unreadable | Adjust `_darkBackground` or `_tacticalGreen` colors |

---

## Performance Checklist

- [ ] App loads Survival dashboard in < 500ms
- [ ] Compass updates in real-time (no stuttering)
- [ ] GPS coordinates update smoothly
- [ ] No memory leaks on sensor streams
- [ ] Battery drain acceptable (compare with Maps app)
- [ ] Works fine on 5+ year old phones

---

## What NOT To Do

❌ Don't add `/mastery` endpoint back  
❌ Don't make XP tracking  
❌ Don't lock tools behind levels  
❌ Don't load Google Maps (use offline GPS only)  
❌ Don't make backend required for Survival  
❌ Don't use light theme (dark is required for field use)

---

## Rollback Plan (If Needed)

Keep these files for reference:
- `survival_mastery_controller.dart` (old controller)
- `survival_mastery_model.dart` (old model)
- `old_router.py` (old backend code)

But we don't recommend rolling back - the new design is much better! 🚀

---

**Last Updated:** February 5, 2026  
**Status:** Ready to Deploy
