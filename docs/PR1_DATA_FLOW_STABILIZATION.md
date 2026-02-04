# PR 1: Data Flow Stabilization

**Status**: ✅ **IMPLEMENTED - READY FOR TESTING**

**Goal**: Pastikan UI benar-benar pakai backend data, bukan legacy logic.

---

## ✅ Checklist PR 1

### 1. Matikan Legacy Path ✅
- [x] Identifikasi legacy models: `UnitModel`, `LessonNode`
- [x] Buat model baru: `LearningPathResponse`, `PathUnit`, `PathLevel`
- [x] Legacy models tetap ada (untuk migration gradual)
- [x] UI utama akan pakai model baru

### 2. Update TrainingController ✅
- [x] Buat `TrainingControllerV2` dengan:
  - ✅ `fetchPath(String sectionId)` - Backend-driven
  - ✅ `fetchProgress()` - Backend-driven
  - ✅ NO mock data (removed userXp, userStreak, userHearts)
  - ✅ NO unlock computation
  - ✅ All state dari API

**File**: `lib/features/training/logic/training_controller_v2.dart`

### 3. Update TrainingRepository ✅
- [x] Buat `TrainingRepositoryV2` sebagai pure pass-through
- [x] NO business logic
- [x] NO data transformation
- [x] NO status computation
- [x] Only: call API → return model

**File**: `lib/features/training/data/repositories/training_repository_v2.dart`

### 4. Progress State Models ✅
- [x] Buat `ProgressStateResponse` model
- [x] Buat `SectionProgressState`, `UnitProgressState`, `LevelProgressState`
- [x] Helper method: `getLevelProgress(levelId)`

**File**: `lib/features/training/data/models/progress_state.dart`

### 5. Dependencies ✅
- [x] Tambahkan `dio: ^5.4.0` ke `pubspec.yaml`
- [x] Update `TrainingApiService` untuk pakai `Environment.apiBaseUrl`

---

## 🧪 Testing Checklist

### Manual Testing (WAJIB sebelum merge)

1. **Test API Connection**
   ```bash
   # Pastikan backend running
   cd scout_os_backend
   source venv/bin/activate
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Test Endpoint di Flutter**
   - [ ] GET `/training/sections/puk/path` → Should return JSON
   - [ ] Log response di `TrainingControllerV2.fetchPath()`
   - [ ] Verify `LearningPathResponse` parsed correctly

3. **Test Error Handling**
   - [ ] Backend off → Should show error message
   - [ ] Invalid section ID → Should show 404 error
   - [ ] Network timeout → Should show timeout error

4. **Verify NO Legacy Logic**
   - [ ] Search codebase for `if (prevCompleted)`
   - [ ] Search for `if (index == 0)`
   - [ ] Search for mock data (userXp, userStreak)
   - [ ] All should be removed or commented

---

## 📁 Files Created/Modified

### New Files
- ✅ `lib/features/training/logic/training_controller_v2.dart`
- ✅ `lib/features/training/data/repositories/training_repository_v2.dart`
- ✅ `lib/features/training/data/models/progress_state.dart`

### Modified Files
- ✅ `pubspec.yaml` - Added dio dependency
- ✅ `lib/features/training/data/services/training_api_service.dart` - Use Environment

### Legacy Files (Keep for now)
- ⚠️ `lib/features/training/logic/training_controller.dart` - Old controller
- ⚠️ `lib/features/training/data/repositories/training_repository.dart` - Old repository
- ⚠️ `lib/features/training/data/models/training_path.dart` - Legacy models

---

## 🔄 Migration Path

### Step 1: Test New Controller (Current)
1. Update `main.dart` to use `TrainingControllerV2`
2. Test API calls
3. Verify data flow

### Step 2: Update UI (PR 2)
1. Update `training_map_page.dart` to use new models
2. Remove legacy `UnitModel` usage
3. Use `LearningPathResponse` instead

### Step 3: Cleanup (After PR 2)
1. Remove old controller
2. Remove old repository
3. Remove legacy models

---

## ⚠️ Important Notes

### Backend Status
- ✅ Learning path endpoint: `/training/sections/{id}/path` - **READY**
- ⚠️ Progress endpoint: `/training/progress/state` - **NOT YET IMPLEMENTED**
  - Stubbed in controller (returns empty progress)
  - Will be implemented in PR 4

### Current Behavior
- Learning path: ✅ Fetches from backend
- Progress state: ⚠️ Returns empty (all locked) until backend ready
- Level status: ⚠️ Defaults to "locked" until progress endpoint ready

### Next Steps (PR 2)
1. Update `training_map_page.dart` to use `TrainingControllerV2`
2. Map level status from backend (when available)
3. Implement section gating from `isUnlocked` field

---

## 🐛 Known Issues

1. **Progress endpoint not ready**
   - Solution: Stubbed in controller, returns empty progress
   - Will be fixed in PR 4

2. **Legacy models still in codebase**
   - Solution: Keep for gradual migration
   - Will be removed after PR 2

---

## ✅ PR 1 Completion Criteria

- [x] Controller uses backend API only
- [x] Repository is pure pass-through
- [x] NO mock data in controller
- [x] NO unlock computation in frontend
- [x] All models match backend schemas
- [x] Error handling implemented
- [x] Dependencies added (dio)

**Status**: ✅ **READY FOR PR 2**

---

**Last Updated**: 2026-01-20
**Next Phase**: PR 2 - Refactor training_map_page.dart
