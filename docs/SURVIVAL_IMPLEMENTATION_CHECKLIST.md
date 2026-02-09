# ✅ Survival Module Refactoring - Implementation Checklist

## Phase 1: Planning & Analysis ✓ DONE

- [x] Analyze current Survival module structure (backend & frontend)
- [x] Identify gamification components to remove
- [x] Plan sensor integration strategy
- [x] Design new dashboard UI
- [x] Document architecture changes

---

## Phase 2: Code Generation ✓ DONE

All code files have been generated and are ready for integration:

### Backend Files Generated
- [x] `router_new.py` - Simplified offline-ready router
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_backend/app/modules/survival/router_new.py`
  - Status: ✓ Ready

### Frontend Files Generated
- [x] `survival_tools_controller.dart` - Main sensor controller
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_app/lib/features/mission/subfeatures/survival/logic/survival_tools_controller.dart`
  - Status: ✓ Ready

- [x] `survival_dashboard_page.dart` - Grid dashboard UI
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_app/lib/features/mission/subfeatures/survival/presentation/pages/survival_dashboard_page.dart`
  - Status: ✓ Ready

- [x] `compass_tool_page.dart` - Compass visualization
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_app/lib/features/mission/subfeatures/survival/presentation/pages/compass_tool_page.dart`
  - Status: ✓ Ready

- [x] `clinometer_tool_page.dart` - Angle measurement
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_app/lib/features/mission/subfeatures/survival/presentation/pages/clinometer_tool_page.dart`
  - Status: ✓ Ready

- [x] `gps_tracker_tool_page.dart` - GPS location tracking
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_app/lib/features/mission/subfeatures/survival/presentation/pages/gps_tracker_tool_page.dart`
  - Status: ✓ Ready

- [x] `survival_repository_new.dart` - Deprecated repository
  - Location: `/home/rafiq/Projek/khasyaraka/scout_os_app/lib/features/mission/subfeatures/survival/data/survival_repository_new.dart`
  - Status: ✓ Ready

### Documentation Files Generated
- [x] `SURVIVAL_MODULE_REFACTORING.md` - Complete refactoring guide
  - Location: `/home/rafiq/Projek/khasyaraka/docs/SURVIVAL_MODULE_REFACTORING.md`
  - Status: ✓ Comprehensive

- [x] `SURVIVAL_MODULE_QUICK_START.md` - Quick implementation guide
  - Location: `/home/rafiq/Projek/khasyaraka/docs/SURVIVAL_MODULE_QUICK_START.md`
  - Status: ✓ Ready

- [x] `SURVIVAL_ARCHITECTURE_DIAGRAMS.md` - Architecture diagrams
  - Location: `/home/rafiq/Projek/khasyaraka/docs/SURVIVAL_ARCHITECTURE_DIAGRAMS.md`
  - Status: ✓ Complete

- [x] `SURVIVAL_CODE_REFERENCE.md` - Complete code examples
  - Location: `/home/rafiq/Projek/khasyaraka/docs/SURVIVAL_CODE_REFERENCE.md`
  - Status: ✓ Complete

---

## Phase 3: Backend Integration

### Step 1: Update Router
- [ ] Copy content of `router_new.py` to `scout_os_backend/app/modules/survival/router.py`
  - [ ] Replace entire file content
  - [ ] Keep imports the same
  - [ ] Remove old XP/Level endpoints

**Test After:**
```bash
curl http://localhost:8000/survival/tools/config
# Expected: 200 OK with tool configuration
```

### Step 2: Register Router in Main API
- [ ] Open `scout_os_backend/app/api/router.py`
- [ ] Verify survival router is included:
  ```python
  from app.modules.survival import router as survival_router
  # ...
  router.include_router(survival_router.router, prefix="/survival", tags=["survival"])
  ```

**Test After:**
```bash
curl http://localhost:8000/survival/health
# Expected: {"status": "ok", "module": "survival"}
```

### Step 3: Database Cleanup (Optional)
- [ ] Decide: Keep or drop `survival_mastery` table
  - [ ] Keep (Recommended): Preserve historical data for analytics
  - [ ] Drop: Run migration to remove unused table

**If dropping:**
```bash
cd scout_os_backend
alembic revision --autogenerate -m "Remove survival gamification"
alembic upgrade head
```

### Step 4: Backend Testing
- [ ] Test `/survival/tools/config` endpoint
  - [ ] Returns correct tool list
  - [ ] No database errors
  - [ ] Correct JSON format

- [ ] Test `/survival/health` endpoint
  - [ ] Returns 200 OK
  - [ ] Indicates offline capability

---

## Phase 4: Frontend Integration

### Step 1: Add Dependencies
- [ ] Open `scout_os_app/pubspec.yaml`
- [ ] Add under `dependencies`:
  ```yaml
  sensors_plus: ^1.4.0
  geolocator: ^9.0.0
  ```
- [ ] Run: `flutter pub get`
- [ ] Verify no conflicts: `flutter pub outdated`

### Step 2: Copy Controller
- [ ] Copy `survival_tools_controller.dart` to:
  - `lib/features/mission/subfeatures/survival/logic/survival_tools_controller.dart`
- [ ] Verify imports are correct
- [ ] Check for any package conflicts

### Step 3: Copy Dashboard Page
- [ ] Copy `survival_dashboard_page.dart` to:
  - `lib/features/mission/subfeatures/survival/presentation/pages/survival_dashboard_page.dart`
- [ ] Verify route references exist

### Step 4: Copy Tool Pages
- [ ] Copy `compass_tool_page.dart` to:
  - `lib/features/mission/subfeatures/survival/presentation/pages/compass_tool_page.dart`
- [ ] Copy `clinometer_tool_page.dart` to:
  - `lib/features/mission/subfeatures/survival/presentation/pages/clinometer_tool_page.dart`
- [ ] Copy `gps_tracker_tool_page.dart` to:
  - `lib/features/mission/subfeatures/survival/presentation/pages/gps_tracker_tool_page.dart`

### Step 5: Update Routes
- [ ] Open `lib/routes/app_routes.dart`
- [ ] Add new route constants:
  ```dart
  static const survivalDashboard = '/survival/dashboard';
  static const survivalCompass = '/survival/compass';
  static const survivalClinometer = '/survival/clinometer';
  static const survivalGpsTracker = '/survival/gps';
  ```

- [ ] Open router configuration (GoRouter/Navigator)
- [ ] Add routes for all 4 pages

### Step 6: Provider Setup
- [ ] Open `lib/main.dart` or `lib/app.dart`
- [ ] Add to MultiProvider:
  ```dart
  ChangeNotifierProvider(
    create: (_) => SurvivalToolsController(),
  ),
  ```

### Step 7: Update Old Imports
- [ ] Search for imports of old controller:
  ```bash
  grep -r "survival_mastery_controller" lib/
  ```
- [ ] Replace with new controller:
  - Old: `import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_mastery_controller.dart';`
  - New: `import 'package:scout_os_app/features/mission/subfeatures/survival/logic/survival_tools_controller.dart';`

- [ ] Update all usages:
  - Old: `SurvivalMasteryController`
  - New: `SurvivalToolsController`

---

## Phase 5: Platform Configuration

### Android Setup
- [ ] Open `android/app/src/main/AndroidManifest.xml`
- [ ] Add permissions (before closing `</manifest>`):
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.BODY_SENSORS" />
  ```

- [ ] Build and test:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### iOS Setup
- [ ] Open `ios/Runner/Info.plist`
- [ ] Add keys:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Survival Tools need location access for GPS tracking.</string>
  
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Survival Tools need location access for GPS tracking.</string>
  
  <key>UIRequiredDeviceCapabilities</key>
  <array>
    <string>gps</string>
    <string>magnetometer</string>
    <string>accelerometer</string>
  </array>
  ```

- [ ] Build and test:
  ```bash
  flutter clean
  flutter pub get
  flutter run -d ios
  ```

---

## Phase 6: Testing

### Unit Tests
- [ ] Test compass direction conversion:
  ```dart
  test('Compass direction calculation', () {
    final controller = SurvivalToolsController();
    expect(controller.getCompassDirection(0), 'N');
    expect(controller.getCompassDirection(45), 'NE');
    expect(controller.getCompassDirection(90), 'E');
    expect(controller.getCompassDirection(180), 'S');
  });
  ```

- [ ] Test altitude interpretation:
  ```dart
  test('Altitude interpretation', () {
    final controller = SurvivalToolsController();
    expect(controller.getAltitudeInfo(50), contains('Low'));
    expect(controller.getAltitudeInfo(300), contains('Moderate'));
  });
  ```

- [ ] Test accuracy levels:
  ```dart
  test('GPS accuracy levels', () {
    final controller = SurvivalToolsController();
    expect(controller.getAccuracyLevel(3), 'Excellent');
    expect(controller.getAccuracyLevel(7), 'Good');
    expect(controller.getAccuracyLevel(25), 'Moderate');
  });
  ```

### Manual Testing - Android
- [ ] Device: Android phone/emulator
- [ ] Test Cases:
  - [ ] Launch app → navigate to Survival → Dashboard loads instantly
  - [ ] Tap Compass → Opens immediately, needle rotates with device
  - [ ] Tap Clinometer → Opens, angles update when tilting
  - [ ] Tap GPS → Requests permission, shows coordinates after lock
  - [ ] Disconnect WiFi → All tools still work
  - [ ] Disconnect cellular → All tools still work
  - [ ] Disable internet → Dashboard loads, tools function normally

### Manual Testing - iOS
- [ ] Device: iPhone
- [ ] Same test cases as Android
- [ ] Additional:
  - [ ] Check Info.plist permissions are requested correctly
  - [ ] Verify background location (if implemented)

### Offline Testing
- [ ] Enable Airplane Mode
- [ ] Verify Compass works ✓
- [ ] Verify Clinometer works ✓
- [ ] Verify GPS works (using cached data) ✓
- [ ] All tests pass

### Performance Testing
- [ ] Measure Dashboard load time: < 500ms
- [ ] Measure Compass update rate: 30-100 Hz
- [ ] Measure Clinometer update rate: 50-200 Hz
- [ ] Measure GPS update rate: 1 Hz
- [ ] Monitor memory usage (no leaks)
- [ ] Monitor battery drain (compare with Maps app)

---

## Phase 7: Cleanup

### Remove Old Files (After Testing)
- [ ] Delete old `survival_mastery_controller.dart`
- [ ] Delete old `survival_mastery_model.dart`
- [ ] Delete old `survival_tools_page.dart` (if not used elsewhere)
- [ ] Update `survival_repository.dart` to point to new offline version

**But Keep:**
- [ ] `models.py` (backend) - for historical data
- [ ] Database tables - for analytics

### Code Quality
- [ ] Run `flutter analyze`
- [ ] Fix any warnings or errors
- [ ] Run `flutter format lib/features/mission/subfeatures/survival/`
- [ ] Verify no unused imports
- [ ] Check for proper null safety

### Documentation
- [ ] Update project README (if needed)
- [ ] Add Survival module to main documentation
- [ ] Document any custom configurations
- [ ] Add troubleshooting section

---

## Phase 8: Deployment

### Pre-Deployment Checklist
- [ ] All tests passing ✓
- [ ] No console errors or warnings ✓
- [ ] Code review completed ✓
- [ ] Backend updated and tested ✓
- [ ] Android build passes ✓
- [ ] iOS build passes ✓

### Release Notes
- [ ] Document what changed:
  - Removed: Levels, XP, progression system
  - Added: Direct sensor integration
  - Changed: UI from levels to utility dashboard
  
- [ ] User impact:
  - Survival tools now work offline
  - No progression/gamification
  - Instant access to all tools

### Deploy Steps
- [ ] Tag version: `v1.0-survival-refactor`
- [ ] Merge to main branch
- [ ] Build APK/IPA
- [ ] Upload to Play Store/App Store
- [ ] Create release notes
- [ ] Notify team

---

## Phase 9: Post-Deployment

### Monitoring
- [ ] Monitor crash reports (Firebase)
- [ ] Monitor analytics (tool usage)
- [ ] Check user reviews/feedback
- [ ] Monitor performance metrics

### Feedback Collection
- [ ] Ask users: "Is Survival toolkit working offline?"
- [ ] Ask users: "Are compass/clinometer/GPS accurate?"
- [ ] Collect suggestions for improvements
- [ ] Log any bugs reported

### Future Enhancements
- [ ] Compass calibration UI
- [ ] Waypoint saving
- [ ] Offline map integration
- [ ] Terrain/elevation data
- [ ] Magnetic declination auto-adjustment

---

## Rollback Plan (If Needed)

**If critical issues arise:**

1. Immediately revert to previous APK/IPA
2. Disable Survival menu item (if possible)
3. Document issue
4. Investigate in test environment
5. Create fix
6. Re-test thoroughly
7. Deploy fix

**Rollback files (keep for 30 days):**
- Previous APK (surviva-old-v0.9.apk)
- Previous IPA (survival-old-v0.9.ipa)
- Old controller code (in git history)
- Old backend router (in git history)

---

## Sign-Off

| Role | Name | Date | Status |
|------|------|------|--------|
| Backend Lead | _ | _ | Pending |
| Frontend Lead | _ | _ | Pending |
| QA Lead | _ | _ | Pending |
| Product Manager | _ | _ | Pending |

---

## Final Summary

✅ **Total Code Files Generated:** 7  
✅ **Total Documentation Files:** 4  
✅ **Total Test Cases:** 20+  
✅ **Expected Deployment Time:** 2-3 hours  
✅ **Expected Testing Time:** 1-2 hours  

**Status:** READY FOR PRODUCTION INTEGRATION

---

**Checklist Version:** 1.0  
**Generated:** February 5, 2026  
**Last Updated:** February 5, 2026
