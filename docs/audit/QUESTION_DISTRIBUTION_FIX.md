# Fix: Distribusi Soal Per Level

## Masalah
Soal-soal di setiap unit dari unit_2 - unit_4 terlihat panjang dalam satu level saja, padahal di JSON sudah diatur untuk terdistribusi ke beberapa level.

## Root Cause
File `levels.json` mendefinisikan `total_questions: 1` untuk semua level di unit 2-4, padahal file question JSON memiliki lebih banyak soal per level.

### Distribusi Soal Aktual di JSON:
- **Unit 1 (puk_u1)**: 5 soal per level (L1-L5) ✓ Sudah benar
- **Unit 2 (puk_u2)**: 5 soal per level (L1-L5) ✗ levels.json salah (tulis 1)
- **Unit 3 (puk_u3)**: 
  - L1: 8 soal ✗ levels.json salah (tulis 1)
  - L2: 8 soal ✗ levels.json salah (tulis 1)
  - L3-L5: 0 soal (belum ada) ✗ levels.json salah (tulis 1)
- **Unit 4 (puk_u4)**: 1 soal per level (L1-L5) ✓ Sudah benar

## Solusi

### 1. Perbaiki `levels.json`

**File**: `scout_os_backend/app/data/levels.json`

#### Unit 2 (puk_u2):
```json
// BEFORE
{ "id": "puk_u2_l1", ..., "total_questions": 1, "min_correct": 1, ... }

// AFTER
{ "id": "puk_u2_l1", ..., "total_questions": 5, "min_correct": 4, ... }
```

Semua level di unit 2 diubah dari `total_questions: 1` menjadi `5` dengan `min_correct: 4`.

#### Unit 3 (puk_u3):
```json
// Level 1-2: Ada 8 soal
{ "id": "puk_u3_l1", ..., "total_questions": 8, "min_correct": 6, ... }
{ "id": "puk_u3_l2", ..., "total_questions": 8, "min_correct": 6, ... }

// Level 3-5: Belum ada soal
{ "id": "puk_u3_l3", ..., "total_questions": 0, "min_correct": 0, ... }
{ "id": "puk_u3_l4", ..., "total_questions": 0, "min_correct": 0, ... }
{ "id": "puk_u3_l5", ..., "total_questions": 0, "min_correct": 0, ... }
```

### 2. Jalankan Seeder

```bash
cd scout_os_backend
source venv/bin/activate
python seed_pramuka_data.py
```

Seeder akan:
1. Update field `total_questions` di tabel `training_levels`
2. Auto-sync dengan menghitung jumlah soal aktual dari `training_questions`

### 3. Cleanup Manual (Jika Ada Data Duplikat)

Beberapa level di unit 3 (L3-L5) memiliki soal duplikat dari seeding sebelumnya. Soal-soal ini **tidak ada di JSON** tapi ada di database.

```sql
-- Hapus soal yang tidak seharusnya ada
DELETE FROM training_questions 
WHERE level_id IN ('puk_u3_l3', 'puk_u3_l4', 'puk_u3_l5');

-- Update total_questions
UPDATE training_levels
SET total_questions = 0
WHERE id IN ('puk_u3_l3', 'puk_u3_l4', 'puk_u3_l5');
```

## Verifikasi

### Backend Verification
```bash
cd scout_os_backend
source venv/bin/activate
python -c "
import asyncio
from app.db.session import SessionLocal
from sqlalchemy import text

async def check():
    async with SessionLocal() as session:
        result = await session.execute(text('''
            SELECT 
                tl.unit_id,
                tl.level_number,
                tl.total_questions,
                COUNT(tq.id) as actual
            FROM training_levels tl
            LEFT JOIN training_questions tq ON tq.level_id = tl.id
            WHERE tl.unit_id IN ('puk_u1', 'puk_u2', 'puk_u3', 'puk_u4')
            GROUP BY tl.unit_id, tl.level_number, tl.total_questions
            ORDER BY tl.unit_id, tl.level_number
        '''))
        for row in result:
            print(f'{row[0]} L{row[1]}: Expected={row[2]}, Actual={row[3]}')

asyncio.run(check())
"
```

### Expected Result:
```
Unit ID    | Level | Expected | Actual | Status
-------------------------------------------------------
puk_u1     | L1    |        5 |      5 | ✓
puk_u1     | L2    |        5 |      5 | ✓
puk_u1     | L3    |        5 |      5 | ✓
puk_u1     | L4    |        5 |      5 | ✓
puk_u1     | L5    |        5 |      5 | ✓
puk_u2     | L1    |        5 |      5 | ✓
puk_u2     | L2    |        5 |      5 | ✓
puk_u2     | L3    |        5 |      5 | ✓
puk_u2     | L4    |        5 |      5 | ✓
puk_u2     | L5    |        5 |      5 | ✓
puk_u3     | L1    |        8 |      8 | ✓
puk_u3     | L2    |        8 |      8 | ✓
puk_u3     | L3    |        0 |      0 | ✓
puk_u3     | L4    |        0 |      0 | ✓
puk_u3     | L5    |        0 |      0 | ✓
puk_u4     | L1    |        1 |      1 | ✓
puk_u4     | L2    |        1 |      1 | ✓
puk_u4     | L3    |        1 |      1 | ✓
puk_u4     | L4    |        1 |      1 | ✓
puk_u4     | L5    |        1 |      1 | ✓
```

### Frontend Testing

1. **Start Backend**:
   ```bash
   cd scout_os_backend
   source venv/bin/activate
   uvicorn app.main:app --reload
   ```

2. **Test API Endpoints**:
   ```bash
   # Unit 2 Level 1 (should return 5 questions)
   curl http://localhost:8000/api/v1/training/levels/puk_u2_l1/questions
   
   # Unit 3 Level 1 (should return 8 questions)
   curl http://localhost:8000/api/v1/training/levels/puk_u3_l1/questions
   
   # Unit 4 Level 1 (should return 1 question)
   curl http://localhost:8000/api/v1/training/levels/puk_u4_l1/questions
   ```

3. **Test Flutter App**:
   - Buka app dan navigasi ke Training
   - Pilih unit 2, mulai level 1
   - Pastikan ada **5 soal** (bukan semua soal dalam 1 level)
   - Ulangi untuk unit 3 level 1 (harus ada **8 soal**)

## Dampak

### ✅ Yang Sudah Diperbaiki:
1. **Backend**: Database sudah sync dengan distribusi soal yang benar
2. **Data**: `levels.json` sudah sesuai dengan JSON soal
3. **Seeder**: Auto-sync mencegah mismatch di masa depan

### ⚠️ Catatan Penting:
- **Unit 3 Level 3-5**: Belum ada soal. Frontend harus handle kasus `total_questions: 0`
- **Min Correct**: Disesuaikan dengan jumlah soal:
  - 5 soal → min_correct = 4 (80%)
  - 8 soal → min_correct = 6 (75%)
  - 1 soal → min_correct = 1 (100%)

## Frontend Handling (Opsional)

Jika ada level dengan `total_questions: 0`, frontend sebaiknya:

```dart
// training_map_page.dart
if (lesson.totalQuestions == 0) {
  return Container(
    child: Text('Coming Soon'),
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.3),
    ),
  );
}
```

Atau hide level yang belum punya soal dari path.

## Status: ✅ SELESAI

Tanggal: 2026-01-21  
Versi Backend: v1.0  
Database: PostgreSQL (Railway)

---

**Author**: AI Assistant  
**Reviewer**: Rafiq (Developer)
