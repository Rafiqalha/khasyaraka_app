# 🔨 Survival Module Refactoring - Complete Implementation Guide

## Overview

The **Survival Module** has been successfully refactored from a **gamified progression system** (Levels, XP, Streaks) into a **pure utility toolkit** with **100% offline operation** using device sensors.

---

## Architecture Changes

### Before: Gamified Progression Model
```
┌─────────────────────────────────────────────────────┐
│         Survival Module (Game-like)                 │
├─────────────────────────────────────────────────────┤
│ ❌ Levels & XP tracking                             │
│ ❌ Progress/Progression system                      │
│ ❌ HTTP calls to FastAPI backend                    │
│ ❌ Database tables (SurvivalMastery)                │
│ ❌ Leaderboard integration                          │
└─────────────────────────────────────────────────────┘
```

### After: Offline Utility Toolkit
```
┌─────────────────────────────────────────────────────┐
│      Survival Tools Dashboard (Pure Utility)        │
├─────────────────────────────────────────────────────┤
│ ✅ 3 Accessible Tools (Grid Layout)                 │
│ ✅ No Levels, No XP, No Locks                       │
│ ✅ Zero HTTP Calls (100% Offline)                   │
│ ✅ Direct Device Sensors                            │
│ ✅ Tactical Dark UI Theme                           │
│ ✅ Real-time Sensor Data Display                    │
└─────────────────────────────────────────────────────┘
```

---

## Backend Changes

### **📁 File: `scout_os_backend/app/modules/survival/router_new.py`**

**What's Changed:**
- ❌ Removed all gamification endpoints (`/mastery`, `/action`)
- ✅ Added minimal config-only API
- ✅ No database queries needed
- ✅ Backend is now optional (can work fully offline)

**New Endpoints:**

| Endpoint | Method | Purpose | Required? |
|----------|--------|---------|-----------|
| `/tools/config` | GET | Get tool config (static) | Optional |
| `/health` | GET | Health check | Optional |

**Example Response:**
```json
{
  "tools": {
    "compass": {
      "name": "🧭 Kompas",
      "description": "Real-time magnetic heading",
      "available": true
    },
    "clinometer": {
      "name": "📐 Klinometer",
      "description": "Angle/Height Measure",
      "available": true
    },
    "gps": {
      "name": "📍 GPS Tracker",
      "description": "Offline GPS location data",
      "available": true
    }
  },
  "message": "All survival tools are 100% offline!"
}
```

### **Database Changes (Optional Migration)**

If you want to clean up the database, create this Alembic migration:

```python
# alembic/versions/xxxx_remove_survival_gamification.py

"""Remove survival gamification tables"""

from alembic import op

def upgrade():
    # Drop the survival_mastery table if you don't need historical data
    op.drop_table('survival_mastery')

def downgrade():
    # Restore if needed - but we recommend keeping for historical records
    pass
```

**⚠️ Note:** We recommend **keeping** the `survival_mastery` table in the database for historical analytics. Just don't use the endpoints anymore.

---

## Frontend Changes

### **1️⃣ Core Controller: `SurvivalToolsController`**

**📁 File: `lib/features/mission/subfeatures/survival/logic/survival_tools_controller.dart`**

**Features:**
- ✅ Direct sensor initialization (no API calls)
- ✅ Real-time compass (magnetometer) streaming
- ✅ Real-time accelerometer (clinometer) streaming
- ✅ Real-time GPS tracking (with permission handling)
- ✅ Helper methods for data interpretation

**Key Classes:**
```dart
CompassData {
  double heading;          // 0-360°
  double magneticField;    // μT
  int accuracy;           // degrees
}

ClinoData {
  double pitchAngle;       // Forward/back tilt
  double rollAngle;        // Left/right tilt
  double yawAngle;         // Rotation twist
}

GpsData {
  double latitude;
  double longitude;
  double altitude;
  double accuracy;         // meters
  double speed;            // m/s
}
```

**Core Methods:**
```dart
// Initialize all sensors
Future<void> initializeSensors()

// Get compass direction (N, NE, E, etc.)
String getCompassDirection(double heading)

// Get altitude interpretation
String getAltitudeInfo(double altitude)

// Get accuracy level
String getAccuracyLevel(double accuracy)
```

**Required Dependencies (add to `pubspec.yaml`):**
```yaml
dependencies:
  sensors_plus: ^1.4.0        # Accelerometer, magnetometer
  geolocator: ^9.0.0          # GPS/Location
  flutter_compass: ^0.7.0     # Optional: compass wrapper
```

---

### **2️⃣ Dashboard Page: `SurvivalDashboardPage`**

**📁 File: `lib/features/mission/subfeatures/survival/presentation/pages/survival_dashboard_page.dart`**

**Features:**
- ✅ 2x2 Grid Layout (3 cards visible)
- ✅ Live sensor preview on each card
- ✅ Tactical Dark Theme (Dark blue + bright green)
- ✅ High contrast for field readability
- ✅ Instant load (no API waiting)
- ✅ Auto-init sensors on page load

**Theme Colors:**
```dart
_darkBackground = Color(0xFF0D1B2A)    // Very dark blue
_darkCard = Color(0xFF1B2F47)          // Dark blue-gray
_tacticalGreen = Color(0xFF00D084)     // Bright green
_accentOrange = Color(0xFFFF6B35)      // Tactical orange
_textLight = Color(0xFFE0E0E0)         // Light gray
```

**UI Structure:**
```
┌────────────────────────────────────┐
│      SURVIVAL KIT (AppBar)         │
├────────────────────────────────────┤
│  ┌──────────────┬──────────────┐  │
│  │ 🧭 Compass   │ 📐 Clinometer│  │
│  │ 45.2° NE    │ Pitch: 12.5° │  │
│  │ [TAP]       │ [TAP]        │  │
│  └──────────────┴──────────────┘  │
│  ┌──────────────────────────────┐  │
│  │ 📍 GPS Tracker               │  │
│  │ 37.7749°N, 122.4194°W        │  │
│  │ [TAP]                        │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

---

### **3️⃣ Tool Pages**

#### **Compass Tool Page**
**📁 File: `lib/features/mission/subfeatures/survival/presentation/pages/compass_tool_page.dart`**

**Features:**
- ✅ Large circular compass rose visualization
- ✅ Real-time needle rotation
- ✅ Degree & cardinal direction display
- ✅ Magnetic field strength readout
- ✅ Accuracy indicator

**Display:**
```
      N (North) ↑
        |
   ◆   ◆   ◆    (Cardinal points)
        |
    ┌───────────┐
    │     ↑ 45° │
    │   45.2° NE│  (Heading + Direction)
    │           │
    │  M: 50 μT │  (Magnetic field)
    └───────────┘
        |
      S (South)
```

---

#### **Clinometer Tool Page**
**📁 File: `lib/features/mission/subfeatures/survival/presentation/pages/clinometer_tool_page.dart`**

**Features:**
- ✅ 3-axis angle display (Pitch, Roll, Yaw)
- ✅ Progress bars for each axis
- ✅ 3D orientation visualization
- ✅ Usage tips for field measurement
- ✅ Real-time accelerometer data

**Use Cases:**
- Measure height of objects (Pitch angle)
- Measure slope/level surfaces (Roll angle)
- Measure rotation/bearing changes (Yaw angle)

---

#### **GPS Tracker Tool Page**
**📁 File: `lib/features/mission/subfeatures/survival/presentation/pages/gps_tracker_tool_page.dart`**

**Features:**
- ✅ Decimal coordinates with 6-digit precision
- ✅ Altitude with altitude classification
- ✅ Speed readout (converted to km/h)
- ✅ GPS accuracy visualization
- ✅ Tap-to-copy coordinates
- ✅ Permission handling & retry
- ✅ NO map display (fully offline)

**Accuracy Levels:**
- Excellent: < 5m
- Good: 5-10m
- Moderate: 10-20m
- Poor: 20-50m
- Very Poor: > 50m

---

### **4️⃣ Repository (Deprecated)**

**📁 File: `lib/features/mission/subfeatures/survival/data/survival_repository_new.dart`**

```dart
@deprecated
Future<void> fetchMastery() {
  throw UnsupportedError(
    'Survival module is now 100% OFFLINE. '
    'Use SurvivalToolsController instead.'
  );
}
```

All methods throw `UnsupportedError` with clear messages. Keep this for compatibility but don't use.

---

## Migration Checklist

### ✅ Backend Cleanup
- [ ] Copy `router_new.py` content to `router.py` (or create new router)
- [ ] Update `app/api/router.py` to include new survival router
- [ ] (Optional) Create Alembic migration to drop gamification tables
- [ ] Test `/survival/tools/config` endpoint
- [ ] Test `/survival/health` endpoint

### ✅ Frontend Setup
- [ ] Add to `pubspec.yaml`:
  ```yaml
  sensors_plus: ^1.4.0
  geolocator: ^9.0.0
  ```
- [ ] Run: `flutter pub get`
- [ ] Copy new files to `lib/features/mission/subfeatures/survival/`:
  - `logic/survival_tools_controller.dart` (new)
  - `presentation/pages/survival_dashboard_page.dart` (new)
  - `presentation/pages/compass_tool_page.dart` (new)
  - `presentation/pages/clinometer_tool_page.dart` (new)
  - `presentation/pages/gps_tracker_tool_page.dart` (new)

### ✅ Routing Updates
Update `lib/routes/app_routes.dart`:
```dart
class AppRoutes {
  // Survival routes
  static const survivalDashboard = '/survival/dashboard';
  static const survivalCompass = '/survival/compass';
  static const survivalClinometer = '/survival/clinometer';
  static const survivalGpsTracker = '/survival/gps';
}
```

### ✅ Provider Setup
Update main.dart or app initialization:
```dart
ChangeNotifierProvider(
  create: (_) => SurvivalToolsController(),
),
```

### ✅ Permissions (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BODY_SENSORS" />
```

### ✅ Permissions (iOS)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Need location for GPS Tracker tool</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Need location for GPS Tracker tool</string>
```

---

## Testing

### Unit Tests
```dart
// Test compass data conversion
test('Compass direction conversion', () {
  final controller = SurvivalToolsController();
  expect(controller.getCompassDirection(0), 'N');
  expect(controller.getCompassDirection(45), 'NE');
  expect(controller.getCompassDirection(90), 'E');
});

// Test altitude interpretation
test('Altitude interpretation', () {
  final controller = SurvivalToolsController();
  expect(controller.getAltitudeInfo(50), 'Low altitude');
  expect(controller.getAltitudeInfo(300), 'Moderate altitude');
});
```

### Manual Testing Checklist
- [ ] Launch app and navigate to Survival dashboard
- [ ] Verify all 3 tool cards load instantly (no API calls)
- [ ] Open Compass tool, verify needle rotation follows device
- [ ] Open Clinometer tool, verify angles update as device tilts
- [ ] Open GPS tool, request location permission, verify coordinates appear
- [ ] Test offline: disconnect internet, verify all tools still work
- [ ] Verify dark theme readability in sunlight
- [ ] Test on both Android and iOS devices

---

## Performance Benefits

### Before (Old Gamified System)
- ⏱️ 2-3 second load time (API call)
- 📊 Database queries for XP/levels
- 🌐 Requires internet connection
- 💾 Large database tables

### After (New Offline Toolkit)
- ⚡ Instant load (no API)
- 📱 Direct device sensor access
- ✈️ 100% works offline
- 🎯 Minimal memory footprint
- 🔋 Better battery optimization (direct sensor use)

---

## Key Decisions

### Why No Gamification?
Survival tools should be **practical utilities**, not games. Users need them to work reliably in the field without "unlocking" or progression barriers.

### Why Offline-Only?
- GPS itself is often offline-capable
- Field conditions may lack connectivity
- Faster response (no network latency)
- Better battery life
- User privacy (no location tracking to server)

### Why Tactical Dark Theme?
- High contrast for outdoor readability
- Bright green on dark blue = military standard
- Reduces eye strain in bright sunlight
- Saves battery on OLED screens

---

## Future Enhancements

Optional features to add later:

1. **Compass Calibration:** Circle device to calibrate magnetometer
2. **Clinometer Export:** Save height measurements to file
3. **GPS Waypoints:** Mark and save locations locally
4. **Offline Maps:** Integrate Vector tiles (if needed later)
5. **Terrain Data:** Show elevation contours
6. **Magnetic Declination:** Auto-adjust for local declination

---

## Support & Troubleshooting

### Compass not working
- Device needs a magnetometer (built-in on modern phones)
- Move away from magnetic interference (power lines, etc.)
- Calibrate by rotating device in figure-8 pattern

### GPS stuck acquiring signal
- Need clear sky view
- Cold start may take 30+ seconds first time
- Walk around slowly to help acquisition
- Verify location permission granted

### Clinometer angles seem off
- Place device flat on table, verify 0° pitch/roll
- If not 0°, device may need accelerometer calibration

---

## File Summary

| File | Status | Purpose |
|------|--------|---------|
| `router_new.py` | ✅ New | Simplified backend router |
| `survival_tools_controller.dart` | ✅ New | Core sensor controller |
| `survival_dashboard_page.dart` | ✅ New | Main dashboard UI |
| `compass_tool_page.dart` | ✅ New | Compass visualization |
| `clinometer_tool_page.dart` | ✅ New | Angle measurement |
| `gps_tracker_tool_page.dart` | ✅ New | Location tracking |
| `survival_repository_new.dart` | ✅ New | Deprecated (offline-only) |
| `survival_mastery_controller.dart` | ❌ Delete | Old gamification |
| `survival_mastery_model.dart` | ❌ Delete | Old gamification |
| `models.py` | ⚠️ Keep | For historical data only |

---

**Status:** ✅ Complete & Ready for Integration

**Date:** February 5, 2026

