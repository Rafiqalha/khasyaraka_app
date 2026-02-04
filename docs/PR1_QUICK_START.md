# PR 1: Quick Start Guide

**Status**: ✅ **READY FOR TESTING**

---

## 🚀 Setup (One-time)

### 1. Install Dependencies
```bash
cd scout_os_app
flutter pub get
```

### 2. Verify Backend Running
```bash
cd scout_os_backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Test Endpoint Manually
```bash
curl http://localhost:8000/api/v1/training/sections/puk/path
```

Should return JSON with units and levels.

---

## 🔄 Migration Steps

### Step 1: Update main.dart (Temporary - for testing)

```dart
// In main.dart, change:
ChangeNotifierProvider(create: (_) => TrainingController()),

// To:
ChangeNotifierProvider(create: (_) => TrainingControllerV2()),
```

### Step 2: Test in Flutter

1. Run app
2. Navigate to training map
3. Check logs for:
   - ✅ API call to `/training/sections/puk/path`
   - ✅ `LearningPathResponse` parsed successfully
   - ✅ No errors

### Step 3: Verify Data Flow

Add debug logs in `TrainingControllerV2`:

```dart
Future<void> fetchPath(String sectionId) async {
  try {
    _learningPath = await _apiService.getLearningPath(sectionId);
    debugPrint("✅ Path loaded: ${_learningPath?.units.length} units");
    debugPrint("✅ First unit: ${_learningPath?.units.first.unitTitle}");
    // ...
  }
}
```

---

## ✅ Success Criteria

After testing, you should see:

1. ✅ No mock data in controller
2. ✅ API calls to real backend
3. ✅ `LearningPathResponse` contains real data
4. ✅ Error handling works (try turning off backend)
5. ✅ No legacy unlock logic

---

## 🐛 Troubleshooting

### Issue: "Connection refused"
- **Solution**: Check backend is running on port 8000
- **Check**: `Environment.apiBaseUrl` matches your setup

### Issue: "404 Not Found"
- **Solution**: Verify section ID exists in database
- **Check**: Use `puk` as default section ID

### Issue: "Timeout"
- **Solution**: Increase timeout in `Environment.connectTimeout`
- **Check**: Network connection stable

---

## 📝 Next Steps

After PR 1 is tested and working:

1. **PR 2**: Refactor `training_map_page.dart`
   - Use `TrainingControllerV2`
   - Use `LearningPathResponse` instead of `UnitModel`
   - Map level status from backend

2. **PR 3**: Question Engine
   - Create question type widgets
   - Implement quiz page

3. **PR 4**: Progress Loop
   - Implement progress submission
   - Real-time map updates

---

**Ready for PR 2?** ✅ Yes, if:
- [x] API calls working
- [x] Data parsed correctly
- [x] No errors in logs
- [x] Backend-driven data confirmed
