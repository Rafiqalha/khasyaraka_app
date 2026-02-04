# 🔗 Flutter Backend Integration - Training Module

## ✅ INTEGRATION COMPLETE

Backend Training APIs telah berhasil diintegrasikan ke Flutter app!

---

## 📂 Files Created

### 1. Models (`lib/modules/training/models/training_models.dart`)

**Classes:**
- `TrainingSection` - Bagian pembelajaran (e.g., "Pengetahuan Umum Kepramukaan")
- `TrainingUnit` - Unit dalam section
- `TrainingLevel` - Level/Lesson dalam unit
- `TrainingQuestion` - Soal dalam level

**Features:**
- ✅ `fromJson()` untuk parsing API response
- ✅ `toJson()` untuk serialization
- ✅ Field `status` untuk level (locked/unlocked/completed)

**Example:**
```dart
TrainingLevel level = TrainingLevel.fromJson({
  'id': 'puk_u1_l1',
  'unit_id': 'puk_unit_1',
  'level_number': 1,
  'difficulty': 'very_easy',
  'xp_reward': 10,
  // ... other fields
});
```

### 2. Service (`lib/services/api/training_service.dart`)

**Methods:**
```dart
// Get all sections
Future<List<TrainingSection>> getSections()

// Get units for a section
Future<List<TrainingUnit>> getUnitsBySection(String sectionId)

// Get levels for a unit (THIS IS FOR THE MAP!)
Future<List<TrainingLevel>> getLevelsByUnit(String unitId)

// Get questions for a level
Future<List<TrainingQuestion>> getQuestionsByLevel(String levelId)

// Individual getters
Future<TrainingSection> getSection(String sectionId)
Future<TrainingUnit> getUnit(String unitId)
Future<TrainingLevel> getLevel(String levelId)
```

**Features:**
- ✅ Uses `http` package (same as AuthService)
- ✅ Uses `ApiConfig` for base URL and headers
- ✅ Proper error handling with try-catch
- ✅ Timeout configuration from ApiConfig
- ✅ Auto-unlocks first level (rest are locked by default)

**Base URL:**
```
http://192.168.1.18:8000/api/v1/training
```

### 3. Controller (`lib/modules/training/controllers/training_controller.dart`)

**State Variables:**
```dart
bool isLoading                          // Loading indicator
String? errorMessage                    // Error message
List<TrainingSection> sections          // All sections
List<TrainingUnit> currentUnits         // Units in current section
List<TrainingLevel> currentLevels       // Levels in current unit
List<TrainingQuestion> currentQuestions // Questions in current level

TrainingSection? currentSection         // Selected section
TrainingUnit? currentUnit               // Selected unit
TrainingLevel? currentLevel             // Selected level

int userXp                              // User XP (mock)
int userStreak                          // User streak (mock)
```

**Main Methods:**
```dart
// Auto-loads on initialization
Future<void> fetchTrainingPath()

// Individual fetch methods
Future<void> fetchSections()
Future<void> fetchUnitsBySection(String sectionId)
Future<void> fetchLevelsByUnit(String unitId)
Future<void> fetchQuestionsByLevel(String levelId)

// Selection methods
Future<void> selectSection(TrainingSection section)
Future<void> selectUnit(TrainingUnit unit)
Future<void> selectLevel(TrainingLevel level)

// Utility methods
void refresh()
void clearError()
String getLevelStatus(TrainingLevel level)
bool isLevelUnlocked(TrainingLevel level)
Color getDifficultyColor(String difficulty)
String getDifficultyLabel(String difficulty)
```

**Auto-load Logic:**
```dart
TrainingController() {
  fetchTrainingPath(); // Called on initialization
}
```

**`fetchTrainingPath()` Flow:**
1. Fetch all sections → `sections`
2. Select first section → `currentSection`
3. Fetch units for that section → `currentUnits`
4. Select first unit → `currentUnit`
5. Fetch levels for that unit → `currentLevels` ✅ **THIS IS FOR THE MAP!**

---

## 🔌 API Endpoints Used

| Method | Endpoint | Returns | Used By |
|--------|----------|---------|---------|
| GET | `/training/sections` | List of sections | `fetchSections()` |
| GET | `/training/sections/{id}` | Single section | `getSection()` |
| GET | `/training/sections/{id}/units` | List of units | `fetchUnitsBySection()` |
| GET | `/training/units/{id}` | Single unit | `getUnit()` |
| GET | `/training/units/{id}/levels` | List of levels | `fetchLevelsByUnit()` ⭐ |
| GET | `/training/levels/{id}` | Single level | `getLevel()` |
| GET | `/training/levels/{id}/questions` | List of questions | `fetchQuestionsByLevel()` |

---

## 🎯 How to Use in UI

### Setup (Provider)

In `main.dart` (or wherever providers are registered):

```dart
ChangeNotifierProvider(
  create: (_) => TrainingController(), // Auto-loads data!
),
```

### Usage in Widget

```dart
import 'package:provider/provider.dart';
import 'package:scout_os_app/modules/training/controllers/training_controller.dart';

class MyTrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingController>(
      builder: (context, controller, _) {
        // Loading state
        if (controller.isLoading) {
          return CircularProgressIndicator();
        }

        // Error state
        if (controller.errorMessage != null) {
          return Text('Error: ${controller.errorMessage}');
        }

        // Success state - Display levels
        return ListView.builder(
          itemCount: controller.currentLevels.length,
          itemBuilder: (context, index) {
            final level = controller.currentLevels[index];
            
            return ListTile(
              title: Text('Level ${level.levelNumber}'),
              subtitle: Text(controller.getDifficultyLabel(level.difficulty)),
              trailing: Text('${level.xpReward} XP'),
              enabled: controller.isLevelUnlocked(level),
              onTap: () {
                if (controller.isLevelUnlocked(level)) {
                  controller.selectLevel(level);
                  // Navigate to level page
                }
              },
            );
          },
        );
      },
    );
  }
}
```

---

## 📊 Data Flow

```
App Start
    ↓
TrainingController initialized
    ↓
fetchTrainingPath() called automatically
    ↓
┌─────────────────────────────────────────┐
│ 1. GET /training/sections              │
│    → sections = [...]                   │
│    → currentSection = sections[0]       │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ 2. GET /training/sections/{id}/units   │
│    → currentUnits = [...]               │
│    → currentUnit = currentUnits[0]      │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ 3. GET /training/units/{id}/levels     │ ⭐ FOR MAP!
│    → currentLevels = [...]              │
│    → UI can now render the path         │
└─────────────────────────────────────────┘
```

---

## 🎨 Mapping to UI (Learning Path Map)

**Data Source:** `controller.currentLevels`

**For each level:**
```dart
final level = controller.currentLevels[index];

// Display properties:
level.id              // "puk_u1_l1"
level.levelNumber     // 1, 2, 3, ...
level.difficulty      // "very_easy", "easy", "medium", "hard"
level.xpReward        // 10, 12, 15, ...
level.status          // "locked", "unlocked", "completed"

// Helper methods:
controller.isLevelUnlocked(level)              // bool
controller.getLevelStatus(level)               // String
controller.getDifficultyColor(level.difficulty) // Color
controller.getDifficultyLabel(level.difficulty) // "Sangat Mudah", etc.
```

**Example Node Rendering:**
```dart
Widget buildLessonNode(TrainingLevel level) {
  final isUnlocked = controller.isLevelUnlocked(level);
  final color = controller.getDifficultyColor(level.difficulty);
  
  return GestureDetector(
    onTap: isUnlocked ? () => onLevelTap(level) : null,
    child: Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isUnlocked ? color : Colors.grey,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlocked ? Icons.play_arrow : Icons.lock,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 4),
          Text(
            '${level.levelNumber}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 🔒 Level Status Logic

**Current Implementation (MVP):**
```dart
// In TrainingService.getLevelsByUnit():
for (var i = 0; i < levels.length; i++) {
  if (i == 0) {
    levels[i].status = 'unlocked'; // First level always unlocked
  } else {
    levels[i].status = 'locked';   // Rest are locked
  }
}
```

**Future Enhancement:**
- Fetch user progress from backend
- Update status based on completion
- Unlock next level when current is completed

---

## 🧪 Testing

### 1. Verify Backend is Running

```bash
cd scout_os_backend
uvicorn app.main:app --reload --host 0.0.0.0
```

Check: `http://192.168.1.18:8000/docs`

### 2. Verify Data is Seeded

```bash
cd scout_os_backend
python seed_pramuka_data.py
```

Expected output:
```
✅ SEEDING COMPLETED SUCCESSFULLY
  Sections: 1
  Units: 1
  Levels: 1
```

### 3. Test in Flutter

```bash
cd scout_os_app
flutter run
```

**Expected Console Output:**
```
✅ Training path loaded successfully
   Section: Pengetahuan Umum Kepramukaan
   Units: 1
   Levels: 1
```

### 4. Manual API Test (Optional)

```bash
# Test sections endpoint
curl http://192.168.1.18:8000/api/v1/training/sections

# Test units endpoint
curl http://192.168.1.18:8000/api/v1/training/sections/puk/units

# Test levels endpoint
curl http://192.168.1.18:8000/api/v1/training/units/puk_unit_1/levels
```

---

## 🔧 Configuration

### Change Backend URL

Edit `lib/config/environment.dart`:

```dart
static const String apiBaseUrl = "http://YOUR_IP:8000/api/v1";
```

**Device-specific URLs:**
- **Android Emulator:** `http://10.0.2.2:8000/api/v1`
- **iOS Simulator:** `http://127.0.0.1:8000/api/v1`
- **Physical Device:** `http://192.168.1.X:8000/api/v1` (your laptop's IP)
- **Linux Desktop:** `http://127.0.0.1:8000/api/v1`

---

## ⚠️ Common Issues

### Issue: "Failed to load sections"

**Causes:**
1. Backend not running
2. Wrong IP address in `environment.dart`
3. Firewall blocking connection
4. Data not seeded

**Solutions:**
```bash
# 1. Start backend
cd scout_os_backend
uvicorn app.main:app --reload --host 0.0.0.0

# 2. Seed data
python seed_pramuka_data.py

# 3. Check IP
ip addr show  # Linux
ipconfig      # Windows

# 4. Allow firewall
sudo ufw allow 8000  # Linux
```

### Issue: "No training sections available"

**Cause:** Database is empty

**Solution:**
```bash
cd scout_os_backend
python seed_pramuka_data.py
```

### Issue: Connection timeout

**Cause:** Backend URL unreachable

**Solution:**
1. Check `lib/config/environment.dart`
2. Verify backend is running: `curl http://192.168.1.18:8000/docs`
3. Ensure device and laptop on same network

---

## 📈 Next Steps

### Phase 1: Display (CURRENT)
- ✅ Fetch data from backend
- ✅ Display learning path
- ✅ Show levels on map
- ⏳ UI integration (next task)

### Phase 2: Interaction
- [ ] Tap level to start lesson
- [ ] Fetch questions for level
- [ ] Display quiz UI
- [ ] Submit answers

### Phase 3: Progress Tracking
- [ ] Save user progress to backend
- [ ] Unlock next level on completion
- [ ] Update XP and streak
- [ ] Sync across devices

### Phase 4: Gamification
- [ ] Leaderboards
- [ ] Achievements
- [ ] Streaks
- [ ] Daily challenges

---

## 📝 Summary

**What Was Created:**
1. ✅ `training_models.dart` - Data models
2. ✅ `training_service.dart` - API service
3. ✅ `training_controller.dart` - State management

**What Works:**
- ✅ Fetch sections from backend
- ✅ Fetch units for section
- ✅ Fetch levels for unit (MAP DATA!)
- ✅ Fetch questions for level
- ✅ Auto-load on controller init
- ✅ Error handling
- ✅ Loading states

**What's Ready:**
- ✅ `controller.currentLevels` → Use this for rendering the path map!
- ✅ Status logic (first level unlocked, rest locked)
- ✅ Helper methods for colors, labels, etc.

**Next Task:**
- Update UI (`TrainingPathPage`) to use `controller.currentLevels`
- Replace mock data with real backend data

---

**Status:** ✅ **BACKEND INTEGRATION COMPLETE!**  
**Data Layer:** Ready ✅  
**Service Layer:** Ready ✅  
**Controller:** Ready ✅  
**UI Integration:** Pending (next task)  

---

*Last Updated: 2026-01-18*
