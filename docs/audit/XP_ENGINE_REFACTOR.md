# ✅ REFACTOR XP ENGINE: BERDASARKAN QUESTION_ID YANG BENAR

## 📋 RINGKASAN PERUBAHAN

**Masalah:**
- Backend hanya menerima `correct_answers` (jumlah)
- XP dihitung dari `questions[:correct_answers]` (berdasarkan urutan)
- Ini SALAH karena user tidak selalu benar di soal awal
- XP jadi tidak adil dan tidak akurat

**Solusi:**
- ✅ Backend sekarang menerima `correct_question_ids: List[str]`
- ✅ XP dihitung dari questions yang ID-nya ada di `correct_question_ids`
- ✅ XP akurat berdasarkan soal yang benar-benar dijawab benar

---

## 🔧 PERUBAHAN SCHEMA REQUEST

### **Sebelum (SALAH):**
```json
{
  "level_id": "puk_u1_l1",
  "score": 5,
  "total_questions": 5,
  "correct_answers": 5,
  "time_spent_seconds": 0
}
```

### **Sesudah (BENAR):**
```json
{
  "level_id": "puk_u1_l1",
  "score": 5,
  "total_questions": 5,
  "correct_answers": 5,
  "correct_question_ids": ["q_puk_u1_l1_01", "q_puk_u1_l1_02", "q_puk_u1_l1_03", "q_puk_u1_l1_04", "q_puk_u1_l1_05"],
  "time_spent_seconds": 0
}
```

---

## 🔧 PERUBAHAN KODE

### **1. Flutter: LessonController**

#### **File: `scout_os_app/lib/features/home/logic/lesson_controller.dart`**

**Tambahan:**
```dart
// ✅ CRITICAL: Track which question IDs were answered correctly
List<String> correctQuestionIds = [];
```

**Update `checkAnswer()`:**
```dart
if (isCorrect) {
  score++;
  // ✅ CRITICAL: Track question ID if answered correctly
  if (!correctQuestionIds.contains(q.id)) {
    correctQuestionIds.add(q.id);
    debugPrint('✅ [CHECK_ANSWER] Added correct question ID: ${q.id}');
  }
  userStreak++;
}
```

**Update `finishLesson()`:**
```dart
final response = await _service.submitProgress(
  levelId: currentLevelId,
  score: score,
  totalQuestions: totalQuestions,
  correctAnswers: correctAnswers,
  correctQuestionIds: correctQuestionIds, // ✅ Send list of correct question IDs
  timeSpentSeconds: 0,
);
```

**Update `exitLesson()`:**
```dart
void exitLesson() {
  currentQuestionIndex = 0;
  score = 0;
  correctQuestionIds.clear(); // ✅ Reset correct question IDs
  _resetAnswerState();
  // ...
}
```

---

### **2. Flutter: TrainingService**

#### **File: `scout_os_app/lib/features/home/data/datasources/training_service.dart`**

**Update method signature:**
```dart
Future<Map<String, dynamic>> submitProgress({
  required String levelId,
  required int score,
  required int totalQuestions,
  required int correctAnswers,
  required List<String> correctQuestionIds, // ✅ NEW: List of question IDs answered correctly
  int timeSpentSeconds = 0,
}) async {
  // ...
  body: json.encode({
    'level_id': levelId,
    'score': score,
    'total_questions': totalQuestions,
    'correct_answers': correctAnswers,
    'correct_question_ids': correctQuestionIds, // ✅ NEW: Send list of correct question IDs
    'time_spent_seconds': timeSpentSeconds,
  }),
}
```

---

### **3. Backend: Router**

#### **File: `app/modules/training/router.py`**

**Update endpoint signature:**
```python
async def submit_progress(
    level_id: str = Body(...),
    score: int = Body(...),
    total_questions: int = Body(...),
    correct_answers: int = Body(...),
    correct_question_ids: List[str] = Body(...),  # ✅ NEW: List of question IDs answered correctly
    time_spent_seconds: int = Body(0),
    current_user: dict = Depends(get_current_user),
    service: TrainingService = Depends(get_service)
):
```

**Update call:**
```python
progress = await service.submit_progress(
    user_id=user_id,
    level_id=level_id,
    score=score,
    total_questions=total_questions,
    correct_answers=correct_answers,
    correct_question_ids=correct_question_ids,  # ✅ NEW: Pass correct question IDs
    time_spent_seconds=time_spent_seconds,
)
```

---

### **4. Backend: Service**

#### **File: `app/modules/training/service.py`**

**Update method signature:**
```python
async def submit_progress(
    self,
    user_id: int,
    level_id: str,
    score: int,
    total_questions: int,
    correct_answers: int,
    correct_question_ids: List[str],  # ✅ NEW: List of question IDs answered correctly
    time_spent_seconds: int = 0,
) -> UserProgress:
```

**KODE LAMA (SALAH):**
```python
# ❌ SALAH: Mengambil N questions pertama berdasarkan urutan
questions_to_count = all_questions[:correct_answers]
xp_earned = sum(q.xp for q in questions_to_count)
```

**KODE BARU (BENAR):**
```python
# ✅ BENAR: Mengambil questions berdasarkan ID yang benar
questions_stmt = (
    select(TrainingQuestion)
    .where(
        TrainingQuestion.level_id == level_id,
        TrainingQuestion.id.in_(correct_question_ids),  # ✅ Filter by correct question IDs
        TrainingQuestion.is_active == True
    )
)
questions_result = await self.db.execute(questions_stmt)
correct_questions = questions_result.scalars().all()

# Calculate XP from correct questions
xp_earned = sum(q.xp for q in correct_questions)
```

---

## ✅ VALIDASI

### **1. Validasi Question IDs:**
```python
# ✅ VALIDATION: Ensure all correct_question_ids belong to this level
correct_ids_set = set(correct_question_ids)
invalid_ids = correct_ids_set - all_question_ids
if invalid_ids:
    logger.error(f"❌ [XP_CALC] Invalid question IDs: {invalid_ids}")
    raise ValueError(f"Invalid question IDs: {list(invalid_ids)} do not belong to level {level_id}")
```

### **2. Validasi Length:**
```python
# ✅ VALIDATION: Ensure correct_question_ids length matches correct_answers
if len(correct_question_ids) != correct_answers:
    logger.warning(f"⚠️ [XP_CALC] Mismatch: len(correct_question_ids)={len(correct_question_ids)} != correct_answers={correct_answers}")
```

### **3. Validasi XP Total:**
```python
# ✅ VALIDATION: Ensure xp_earned doesn't exceed expected total
if xp_earned > expected_total_xp:
    logger.warning(f"⚠️ [XP_CALC] WARNING: xp_earned ({xp_earned}) > expected_total_xp ({expected_total_xp})")
    xp_earned = expected_total_xp
```

### **4. Validasi Questions Found:**
```python
# ✅ VALIDATION: Ensure we found all questions
found_question_ids = {q.id for q in correct_questions}
missing_ids = correct_ids_set - found_question_ids
if missing_ids:
    logger.warning(f"⚠️ [XP_CALC] WARNING: Some question IDs not found: {missing_ids}")
```

---

## 📊 CONTOH PERHITUNGAN

**Level: puk_u1_l1**
- Question 1 (q_puk_u1_l1_01): xp = 2
- Question 2 (q_puk_u1_l1_02): xp = 2
- Question 3 (q_puk_u1_l1_03): xp = 3
- Question 4 (q_puk_u1_l1_04): xp = 3
- Question 5 (q_puk_u1_l1_05): xp = 3

**Expected Total XP:** 2 + 2 + 3 + 3 + 3 = **13 XP**

**Scenario 1: User benar di soal 1, 3, 5 (bukan soal awal)**
- correct_question_ids: ["q_puk_u1_l1_01", "q_puk_u1_l1_03", "q_puk_u1_l1_05"]
- Questions found: [q1, q3, q5]
- XP per question: [2, 3, 3]
- **xp_earned = 2 + 3 + 3 = 8 XP** ✅ AKURAT

**Scenario 2: User benar di semua soal**
- correct_question_ids: ["q_puk_u1_l1_01", "q_puk_u1_l1_02", "q_puk_u1_l1_03", "q_puk_u1_l1_04", "q_puk_u1_l1_05"]
- Questions found: [q1, q2, q3, q4, q5]
- XP per question: [2, 2, 3, 3, 3]
- **xp_earned = 2 + 2 + 3 + 3 + 3 = 13 XP** ✅ AKURAT

**Sebelum (SALAH):**
- Jika user benar di soal 1, 3, 5 → XP = 2 + 2 + 3 = 7 XP (salah, karena mengambil 3 soal pertama)
- ❌ Tidak akurat karena tidak sesuai soal yang benar

**Sesudah (BENAR):**
- Jika user benar di soal 1, 3, 5 → XP = 2 + 3 + 3 = 8 XP ✅
- ✅ Akurat karena sesuai soal yang benar-benar dijawab benar

---

## 🎯 HASIL AKHIR

**Sebelum:**
- XP dihitung dari `questions[:correct_answers]` (berdasarkan urutan)
- Tidak akurat jika user benar di soal yang berbeda

**Sesudah:**
- XP dihitung dari `questions WHERE id IN correct_question_ids`
- Akurat berdasarkan soal yang benar-benar dijawab benar
- XP berbeda untuk kombinasi soal yang berbeda

---

## ✅ CHECKLIST VERIFIKASI

- [x] ✅ Flutter tracking `correctQuestionIds` di `LessonController`
- [x] ✅ Flutter mengirim `correct_question_ids` ke backend
- [x] ✅ Backend menerima `correct_question_ids` di endpoint
- [x] ✅ Backend menghitung XP dari question IDs yang benar
- [x] ✅ Validasi: question IDs valid untuk level ini
- [x] ✅ Validasi: length match dengan correct_answers
- [x] ✅ Validasi: xp_earned <= expected_total_xp
- [x] ✅ Logging detail untuk debugging

---

**END OF XP ENGINE REFACTOR DOCUMENTATION**
