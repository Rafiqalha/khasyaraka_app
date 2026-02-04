# Training API Contract

**Single Source of Truth** untuk kontrak API antara Backend (FastAPI) dan Frontend (Flutter).

> ⚠️ **CRITICAL**: Frontend HARUS mengikuti struktur ini 1:1. Tidak boleh ada interpretasi atau transformasi data di frontend.

---

## Base URL

```
Development: http://localhost:8000/api/v1
Production: https://api.scout-os.com/api/v1
```

---

## Authentication

Semua endpoint memerlukan JWT token di header:

```
Authorization: Bearer <token>
```

---

## 1. Section Endpoints

### GET `/training/sections`

**Description**: Get all active training sections

**Response**:
```json
{
  "total": 2,
  "sections": [
    {
      "id": "puk",
      "title": "Pengenalan Umum Kepramukaan",
      "description": "Materi dasar kepramukaan",
      "tier": "free",
      "order": 1,
      "is_active": true,
      "created_at": "2026-01-20T00:00:00Z"
    }
  ]
}
```

**Dart Model**: `SectionListResponse`

---

### GET `/training/sections/{section_id}`

**Description**: Get specific section by ID

**Response**: `TrainingSectionResponse` (same structure as above, single object)

---

### GET `/training/sections/{section_id}/units`

**Description**: Get all units in a section

**Response**:
```json
{
  "total": 5,
  "section_id": "puk",
  "units": [
    {
      "id": "puk_unit_1",
      "section_id": "puk",
      "title": "Sejarah dan Trivia Kepramukaan",
      "description": "Materi tentang sejarah pramuka",
      "order": 1,
      "total_levels": 8,
      "is_active": true,
      "created_at": "2026-01-20T00:00:00Z"
    }
  ]
}
```

**Dart Model**: `UnitListResponse`

---

## 2. Unit Endpoints

### GET `/training/units/{unit_id}`

**Description**: Get specific unit by ID

**Response**: `TrainingUnitResponse` (single unit object)

---

### GET `/training/units/{unit_id}/levels`

**Description**: Get all levels in a unit

**Response**:
```json
{
  "total": 8,
  "unit_id": "puk_unit_1",
  "levels": [
    {
      "id": "puk_u1_l1",
      "unit_id": "puk_unit_1",
      "level_number": 1,
      "difficulty": "very_easy",
      "total_questions": 5,
      "min_correct": 4,
      "xp_reward": 10,
      "unlock_rule": {"type": "start", "value": true},
      "is_active": true,
      "created_at": "2026-01-20T00:00:00Z"
    }
  ]
}
```

**Dart Model**: `LevelListResponse`

---

## 3. Level Endpoints

### GET `/training/levels/{level_id}`

**Description**: Get specific level by ID

**Response**: `TrainingLevelResponse` (single level object)

---

### GET `/training/levels/{level_id}/questions`

**Description**: Get all questions in a level

**Response**:
```json
{
  "total": 5,
  "level_id": "puk_u1_l1",
  "questions": [
    {
      "id": "q_puk_u1_l1_01",
      "level_id": "puk_u1_l1",
      "type": "multiple_choice",
      "question": "Siapa pendiri Gerakan Pramuka Indonesia?",
      "payload": {
        "options": [
          "Sri Sultan Hamengkubuwono IX",
          "Soekarno",
          "Mohammad Hatta",
          "Ahmad Yani"
        ]
      },
      "xp": 2,
      "order": 1,
      "is_active": true,
      "created_at": "2026-01-20T00:00:00Z"
    }
  ]
}
```

**Important**: 
- `payload` structure depends on `type`:
  - `multiple_choice`: `{"options": ["...", "..."]}`
  - `matching`: `{"left_items": [...], "right_items": [...]}`
  - `true_false`: `{"statement": "..."}`
  - `input`: `{"placeholder": "..."}`
  - `ordering`: `{"items": [...]}`

**Dart Model**: `QuestionListResponse`

---

## 4. Learning Path Endpoint (Duolingo-style)

### GET `/training/sections/{section_id}/path`

**Description**: Get structured learning path with section → units → levels

**Response**:
```json
{
  "section_id": "puk",
  "section_title": "Pengenalan Umum Kepramukaan",
  "units": [
    {
      "unit_id": "puk_unit_1",
      "unit_title": "Sejarah dan Trivia Kepramukaan",
      "order": 1,
      "levels": [
        {
          "level_id": "puk_u1_l1",
          "title": "Level 1",
          "level_number": 1,
          "difficulty": "very_easy",
          "xp_reward": 10,
          "status": "unlocked"
        }
      ]
    }
  ]
}
```

**Note**: 
- `status` is currently hardcoded as `"unlocked"` (MVP)
- Future: Will be computed from user progress

**Dart Model**: `LearningPathResponse`

---

## 5. Progress Endpoints (TODO - To Be Implemented)

### POST `/training/progress/submit`

**Description**: Submit level completion and update user progress

**Request**:
```json
{
  "level_id": "puk_u1_l1",
  "score": 5,
  "total_questions": 5,
  "time_spent_seconds": 120,
  "answers": [
    {
      "question_id": "q_puk_u1_l1_01",
      "user_answer": "option_0",
      "is_correct": true
    }
  ]
}
```

**Response**:
```json
{
  "success": true,
  "level_completed": true,
  "xp_earned": 10,
  "next_level_unlocked": "puk_u1_l2",
  "section_progress": {
    "section_id": "puk",
    "completed_units": 0,
    "completed_levels": 1,
    "total_levels": 40
  }
}
```

---

### GET `/training/progress/state`

**Description**: Get current user progress state for all levels

**Response**:
```json
{
  "sections": [
    {
      "section_id": "puk",
      "is_unlocked": true,
      "units": [
        {
          "unit_id": "puk_unit_1",
          "levels": [
            {
              "level_id": "puk_u1_l1",
              "status": "completed",  // locked | available | in_progress | completed
              "progress": 1.0,
              "score": 5,
              "completed_at": "2026-01-20T10:00:00Z"
            },
            {
              "level_id": "puk_u1_l2",
              "status": "available",
              "progress": 0.0
            }
          ]
        }
      ]
    },
    {
      "section_id": "puk_advanced",
      "is_unlocked": false,  // Locked until section 1 complete
      "units": []
    }
  ]
}
```

**Dart Model**: `ProgressStateResponse`

---

## 6. Question Schema Contract

### Question Types & Payload Structure

#### `multiple_choice`
```json
{
  "type": "multiple_choice",
  "payload": {
    "options": ["Option A", "Option B", "Option C", "Option D"]
  }
}
```

#### `matching`
```json
{
  "type": "matching",
  "payload": {
    "left_items": ["Item 1", "Item 2"],
    "right_items": ["Match A", "Match B"]
  }
}
```

#### `true_false`
```json
{
  "type": "true_false",
  "payload": {
    "statement": "Gerakan Pramuka didirikan pada 1961"
  }
}
```

#### `input` (fill_blank)
```json
{
  "type": "input",
  "payload": {
    "placeholder": "Masukkan jawaban..."
  }
}
```

#### `ordering` (word_bank)
```json
{
  "type": "ordering",
  "payload": {
    "items": ["Item 1", "Item 2", "Item 3"]
  }
}
```

---

## 7. Level State Machine

**CRITICAL**: Level state MUST come from backend, NOT computed in frontend.

### State Values:
- `locked`: Cannot be accessed (previous level not completed)
- `available`: Can be started (unlocked but not started)
- `in_progress`: Currently being attempted
- `completed`: Successfully completed

### Business Rules (Backend):
1. Section 1, Level 1 → Always `available` (or `in_progress` if started)
2. Section 1, Level N → `available` if Level N-1 is `completed`
3. Section 2+ → `locked` until all levels in previous section are `completed`

---

## 8. Error Responses

All endpoints return consistent error format:

```json
{
  "detail": "Error message here",
  "status_code": 404
}
```

Common status codes:
- `400`: Bad Request (invalid input)
- `401`: Unauthorized (missing/invalid token)
- `404`: Not Found (resource doesn't exist)
- `500`: Internal Server Error

---

## 9. Frontend Implementation Checklist

- [ ] Create Dart models matching all response schemas
- [ ] Create API service layer with Dio
- [ ] Implement error handling for all endpoints
- [ ] Map level status from backend (no local computation)
- [ ] Implement question type widgets (switch by `type`)
- [ ] Implement progress submission
- [ ] Implement section gating logic (from backend `is_unlocked`)

---

## 10. Versioning

Current API version: `v1`

Future breaking changes will increment to `v2`, `v3`, etc.

---

**Last Updated**: 2026-01-20
**Maintained By**: Backend Team
**Frontend Sync Required**: Yes
