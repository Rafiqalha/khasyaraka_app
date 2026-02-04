# 🔍 LEADERBOARD & XP FLOW - COMPREHENSIVE AUDIT REPORT

**Tanggal Audit:** 2026-01-25  
**Scope:** End-to-end analysis dari Flutter → FastAPI → PostgreSQL → Redis → Flutter

---

## 📊 DIAGRAM ALUR XP FLOW

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FLUTTER (Frontend)                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  QuizPage (User completes level)                                          │
│       │                                                                    │
│       ├─→ LessonController.finishLesson()                                │
│       │       │                                                            │
│       │       ├─→ Calculate XP Reward (15 XP per first completion)       │
│       │       │                                                            │
│       │       ├─→ ProfileRepository.updateUserXp()                        │
│       │       │       │                                                    │
│       │       │       └─→ PUT /api/v1/users/me/stats                     │
│       │       │               │                                            │
│       │       │               └─→ Backend: update_user_stats()            │
│       │       │                       │                                    │
│       │       │                       ├─→ Update users.total_xp           │
│       │       │                       │   (PostgreSQL)                    │
│       │       │                       │                                    │
│       │       │                       └─→ LeaderboardService              │
│       │       │                           .update_user_score()             │
│       │       │                               │                            │
│       │       │                               ├─→ Redis ZADD                │
│       │       │                               │   (leaderboard:training)    │
│       │       │                               │                            │
│       │       │                               └─→ Update users.total_xp     │
│       │       │                                   (PostgreSQL - redundant)  │
│       │       │                                                            │
│       │       └─→ Save level status locally (SharedPreferences)          │
│       │                                                                   │
│       └─→ Navigate to LessonResultPage                                    │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ API Call
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                      FASTAPI (Backend)                                    │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  PUT /api/v1/users/me/stats                                              │
│       │                                                                    │
│       ├─→ users/router.py:update_user_stats()                            │
│       │       │                                                            │
│       │       ├─→ user.total_xp = request.total_xp                        │
│       │       │   (Menggunakan nilai yang dikirim dari Flutter)          │
│       │       │                                                            │
│       │       ├─→ await db.commit()                                       │
│       │       │                                                            │
│       │       └─→ LeaderboardService.update_user_score()                   │
│       │           │                                                        │
│       │           ├─→ Redis: ZADD leaderboard:training {user_id: total_xp} │
│       │           │                                                        │
│       │           └─→ PostgreSQL: user.total_xp = total_xp                 │
│       │               (Redundant update - sudah di-update di atas)        │
│       │                                                                   │
│  POST /api/v1/training/progress/submit                                   │
│       │                                                                    │
│       ├─→ ❌ BUG: user_id = 1 (HARDCODED!)                                │
│       │                                                                    │
│       ├─→ TrainingService.submit_progress()                               │
│       │       │                                                            │
│       │       ├─→ Save UserProgress (user_progress table)                 │
│       │       │                                                            │
│       │       └─→ ❌ BUG: Update leaderboard dengan user.total_xp LAMA     │
│       │           (Tidak update user.total_xp dengan xp_earned)            │
│       │                                                                   │
│  GET /api/v1/leaderboard                                                 │
│       │                                                                    │
│       ├─→ LeaderboardService.get_leaderboard()                            │
│       │       │                                                            │
│       │       ├─→ Redis: ZREVRANGE leaderboard:training 0 limit-1          │
│       │       │   (Get top users by XP descending)                        │
│       │       │                                                            │
│       │       ├─→ PostgreSQL: SELECT users WHERE id IN (...)             │
│       │       │   (Enrich dengan full_name, picture_url)                  │
│       │       │                                                            │
│       │       └─→ Return LeaderboardResponse                              │
│       │                                                                   │
│  GET /api/v1/users/me                                                     │
│       │                                                                    │
│       └─→ Return current user info (total_xp, streak, etc.)              │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Query
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                    POSTGRESQL (Database)                                  │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Table: users                                                             │
│  ├─ id (INTEGER, PK)                                                      │
│  ├─ total_xp (INTEGER, default=0)                                        │
│  ├─ streak (INTEGER, default=0, NOT NULL)                               │
│  ├─ last_active_date (DATE, nullable)                                     │
│  └─ ... (other fields)                                                   │
│                                                                           │
│  Table: user_progress                                                     │
│  ├─ id (INTEGER, PK)                                                     │
│  ├─ user_id (INTEGER, FK → users.id)                                     │
│  ├─ level_id (STRING, FK → training_levels.id)                           │
│  ├─ status (STRING: locked/available/in_progress/completed)              │
│  ├─ xp_earned (INTEGER)                                                  │
│  └─ ... (other fields)                                                  │
│                                                                           │
│  ⚠️ ISSUE: user_progress.xp_earned TIDAK di-aggregate ke users.total_xp  │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Cache
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                      REDIS (Cache)                                        │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Key: leaderboard:training                                                │
│  Type: Sorted Set (ZSET)                                                 │
│                                                                           │
│  Structure:                                                               │
│  ┌─────────────┬──────────┐                                             │
│  │ Member      │ Score    │                                             │
│  ├─────────────┼──────────┤                                             │
│  │ "1"         │ 150      │  ← user_id: total_xp                        │
│  │ "2"         │ 120      │                                             │
│  │ "3"         │ 90       │                                             │
│  └─────────────┴──────────┘                                             │
│                                                                           │
│  Operations:                                                              │
│  - ZADD leaderboard:training {user_id: total_xp}  (Update score)         │
│  - ZREVRANGE leaderboard:training 0 limit-1 WITHSCORES  (Get top users)  │
│  - ZREVRANK leaderboard:training user_id  (Get user rank)               │
│  - ZSCORE leaderboard:training user_id  (Get user XP)                    │
│                                                                           │
│  ⚠️ ISSUE: Jika Redis kosong, leaderboard akan kosong                    │
│  ⚠️ ISSUE: Tidak ada fallback ke PostgreSQL jika Redis down              │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## 🐛 BUG & DESAIN ISSUES YANG DITEMUKAN

### 🔴 **BUG KRITIS #1: Hardcoded user_id di submit_progress endpoint**

**Lokasi:** `scout_os_backend/app/modules/training/router.py:480`

```python
async def submit_progress(...):
    # TODO: Get user_id from authentication token
    # For now, use user_id=1 for testing
    user_id = 1  # ❌ HARDCODED!
```

**Dampak:**
- Semua progress disimpan untuk `user_id=1`, bukan user yang sebenarnya login
- Leaderboard hanya menampilkan user dengan ID=1
- User lain tidak muncul di leaderboard meskipun sudah complete level

**Fix:**
```python
async def submit_progress(
    ...,
    current_user: dict = Depends(get_current_user),  # ✅ Get from JWT
    ...
):
    user_id = int(current_user.get("sub"))  # ✅ Use authenticated user
```

---

### 🔴 **BUG KRITIS #2: submit_progress tidak update user.total_xp**

**Lokasi:** `scout_os_backend/app/modules/training/service.py:296-314`

```python
# CRITICAL: Update leaderboard in Redis when XP is earned
if xp_earned > 0:
    # Get current total XP from user
    user = result.scalar_one_or_none()
    if user:
        # ❌ BUG: Menggunakan user.total_xp LAMA, bukan yang baru
        await leaderboard_service.update_user_score(
            user_id=str(user_id),
            total_xp=user.total_xp  # ❌ Masih nilai lama!
        )
```

**Dampak:**
- Leaderboard tidak ter-update dengan XP yang baru
- User XP di leaderboard selalu tertinggal

**Fix:**
```python
if xp_earned > 0:
    # Update user.total_xp FIRST
    user.total_xp = (user.total_xp or 0) + xp_earned
    await self.db.commit()
    
    # THEN update leaderboard
    await leaderboard_service.update_user_score(
        user_id=str(user_id),
        total_xp=user.total_xp  # ✅ Nilai yang sudah di-update
    )
```

---

### 🟡 **ISSUE #3: Dual update path yang tidak konsisten**

**Masalah:**
- **Path A:** Flutter → `PUT /users/me/stats` → Update `users.total_xp` + Redis
- **Path B:** Backend → `POST /training/progress/submit` → Update `user_progress` + Redis (tapi tidak update `users.total_xp`)

**Dampak:**
- Jika Flutter tidak memanggil `PUT /users/me/stats`, XP tidak ter-update
- Jika backend `submit_progress` dipanggil, XP tidak ter-update ke `users.total_xp`
- Data tidak konsisten antara `users.total_xp` dan `user_progress.xp_earned`

**Rekomendasi:**
- **Pilih SATU source of truth:** `users.total_xp` harus selalu di-update dari `user_progress.xp_earned`
- Atau: Hapus `submit_progress` endpoint jika tidak digunakan
- Atau: Buat trigger/function PostgreSQL untuk auto-update `users.total_xp` dari `user_progress`

---

### 🟡 **ISSUE #4: Redis tidak memiliki fallback ke PostgreSQL**

**Lokasi:** `scout_os_backend/app/modules/gamification/service.py:86-107`

**Masalah:**
- Jika Redis kosong atau down, leaderboard akan kosong
- Tidak ada fallback query ke PostgreSQL untuk populate leaderboard

**Dampak:**
- Leaderboard kosong setelah Redis restart
- User tidak muncul di leaderboard meskipun `users.total_xp` sudah ter-update

**Rekomendasi:**
```python
if not user_ids:
    # Fallback: Query from PostgreSQL
    stmt = select(User).order_by(User.total_xp.desc()).limit(limit)
    result = await self.db.execute(stmt)
    users = result.scalars().all()
    
    # Populate Redis for next time
    for rank, user in enumerate(users, start=1):
        await redis_client.zadd(LEADERBOARD_KEY, {str(user.id): user.total_xp})
```

---

### 🟡 **ISSUE #5: Redundant update di LeaderboardService.update_user_score**

**Lokasi:** `scout_os_backend/app/modules/gamification/service.py:55-62`

**Masalah:**
```python
# Update Redis
await redis_client.zadd(LEADERBOARD_KEY, {user_id: total_xp})

# Also update PostgreSQL (REDUNDANT - sudah di-update di router)
stmt = select(User).where(User.id == int(user_id))
user = result.scalar_one_or_none()
if user:
    user.total_xp = total_xp  # ❌ Redundant
    await self.db.commit()
```

**Dampak:**
- Double commit ke database (inefficient)
- Potensi race condition jika ada concurrent update

**Rekomendasi:**
- Hapus update PostgreSQL dari `LeaderboardService.update_user_score`
- Biarkan router yang handle update PostgreSQL
- `LeaderboardService` hanya handle Redis

---

### 🟡 **ISSUE #6: Flutter tidak memanggil submit_progress**

**Masalah:**
- Flutter hanya memanggil `PUT /users/me/stats` untuk update XP
- Flutter TIDAK memanggil `POST /training/progress/submit`
- Endpoint `submit_progress` ada tapi tidak digunakan

**Dampak:**
- `user_progress` table tidak ter-populate
- Tidak ada history progress per level
- Tidak bisa track `xp_earned` per level

**Rekomendasi:**
- **Option A:** Flutter juga memanggil `submit_progress` setelah `finishLesson`
- **Option B:** Hapus `submit_progress` endpoint jika tidak diperlukan
- **Option C:** Buat background job untuk sync `users.total_xp` dari `user_progress.xp_earned`

---

### 🟡 **ISSUE #7: Leaderboard menggunakan XP dari Redis, bukan PostgreSQL**

**Lokasi:** `scout_os_backend/app/modules/gamification/service.py:127`

**Masalah:**
```python
xp=scores[user_id],  # ✅ Menggunakan XP dari Redis
```

**Dampak:**
- Jika Redis tidak ter-update, leaderboard akan menampilkan XP lama
- Tidak ada single source of truth

**Rekomendasi:**
- **Option A:** Leaderboard selalu query dari PostgreSQL (source of truth)
- **Option B:** Redis sebagai cache, tapi selalu validate dengan PostgreSQL
- **Option C:** Gunakan PostgreSQL untuk leaderboard, Redis hanya untuk caching

---

## ✅ REKOMENDASI ARSITEKTUR PRODUCTION-READY

### **Arsitektur yang Disarankan:**

```
┌─────────────────────────────────────────────────────────────┐
│                    SINGLE SOURCE OF TRUTH                    │
│                  PostgreSQL (users.total_xp)                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Update
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              FastAPI Endpoint (PUT /users/me/stats)         │
│  1. Update users.total_xp                                    │
│  2. Commit to PostgreSQL                                     │
│  3. Update Redis (async, non-blocking)                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Cache
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Redis ZSET (leaderboard:training)              │
│  - Fast read for leaderboard                                 │
│  - Fallback to PostgreSQL if Redis empty                    │
└─────────────────────────────────────────────────────────────┘
```

### **Prinsip:**
1. **PostgreSQL sebagai Source of Truth:** `users.total_xp` selalu di-update di PostgreSQL dulu
2. **Redis sebagai Cache:** Redis hanya untuk performance, bukan source of truth
3. **Fallback Mechanism:** Jika Redis kosong, query dari PostgreSQL dan populate Redis
4. **Single Update Path:** Hanya satu endpoint yang update XP (`PUT /users/me/stats`)

---

## 💻 CONTOH KODE YANG BENAR

### **1. Fix submit_progress endpoint (dengan authentication)**

```python
# scout_os_backend/app/modules/training/router.py

@router.post("/progress/submit")
async def submit_progress(
    level_id: str = Body(...),
    score: int = Body(...),
    total_questions: int = Body(...),
    correct_answers: int = Body(...),
    xp_earned: int = Body(...),
    time_spent_seconds: int = Body(0),
    current_user: dict = Depends(get_current_user),  # ✅ Get from JWT
    service: TrainingService = Depends(get_service)
):
    """Submit user progress for a completed level."""
    # ✅ Use authenticated user ID
    user_id = int(current_user.get("sub"))
    
    progress = await service.submit_progress(
        user_id=user_id,  # ✅ Use authenticated user
        level_id=level_id,
        score=score,
        total_questions=total_questions,
        correct_answers=correct_answers,
        xp_earned=xp_earned,
        time_spent_seconds=time_spent_seconds,
    )
    
    return {
        "success": True,
        "level_id": progress.level_id,
        "status": progress.status,
        "xp_earned": progress.xp_earned,
    }
```

---

### **2. Fix TrainingService.submit_progress (update user.total_xp)**

```python
# scout_os_backend/app/modules/training/service.py

async def submit_progress(
    self,
    user_id: int,
    level_id: str,
    score: int,
    total_questions: int,
    correct_answers: int,
    xp_earned: int,
    time_spent_seconds: int = 0,
) -> UserProgress:
    """Submit user progress for a level."""
    # ... existing code ...
    
    # Save progress
    progress = await self.repository.upsert_user_progress(...)
    
    # If completed, unlock next level
    if status == "completed":
        await self._unlock_next_level(user_id, level)
    
    # ✅ CRITICAL: Update user.total_xp FIRST
    if xp_earned > 0:
        from app.modules.users.models import User
        from sqlalchemy import select
        
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if user:
            # ✅ Update user.total_xp dengan xp_earned
            user.total_xp = (user.total_xp or 0) + xp_earned
            await self.db.commit()
            
            # ✅ THEN update leaderboard dengan nilai yang baru
            try:
                from app.modules.gamification.service import LeaderboardService
                leaderboard_service = LeaderboardService(self.db)
                await leaderboard_service.update_user_score(
                    user_id=str(user_id),
                    total_xp=user.total_xp  # ✅ Nilai yang sudah di-update
                )
            except Exception as e:
                logger.warning(f"⚠️ Failed to update leaderboard: {e}")
    
    return progress
```

---

### **3. Fix LeaderboardService (remove redundant update, add fallback)**

```python
# scout_os_backend/app/modules/gamification/service.py

async def update_user_score(self, user_id: str, total_xp: int) -> None:
    """
    Update user's score in Redis leaderboard.
    
    NOTE: This method assumes user.total_xp is already updated in PostgreSQL.
    This method ONLY updates Redis cache.
    """
    try:
        redis_client = await get_redis()
        
        # ✅ Update Redis Sorted Set (ZSET) only
        await redis_client.zadd(LEADERBOARD_KEY, {user_id: total_xp})
        
        logger.info(f"✅ Updated Redis leaderboard: user_id={user_id}, xp={total_xp}")
        
        # ❌ REMOVED: Redundant PostgreSQL update
        # PostgreSQL should be updated by the caller (router)
        
    except Exception as e:
        logger.error(f"❌ Error updating Redis leaderboard: {e}")
        # Don't raise - Redis failure should not break the request
        # PostgreSQL is still the source of truth


async def get_leaderboard(
    self,
    limit: int = 50,
    current_user_id: Optional[str] = None
) -> LeaderboardResponse:
    """Get leaderboard with top users and current user's rank."""
    try:
        redis_client = await get_redis()
        
        # Get top users from Redis
        top_entries = await redis_client.zrevrange(
            LEADERBOARD_KEY,
            0,
            limit - 1,
            withscores=True
        )
        
        # ✅ FALLBACK: If Redis is empty, query from PostgreSQL
        if not top_entries:
            logger.info("📊 Redis leaderboard empty, falling back to PostgreSQL")
            
            stmt = select(User).order_by(User.total_xp.desc()).limit(limit)
            result = await self.db.execute(stmt)
            users = result.scalars().all()
            
            # Populate Redis for next time
            for user in users:
                await redis_client.zadd(
                    LEADERBOARD_KEY,
                    {str(user.id): user.total_xp or 0}
                )
            
            # Build response from PostgreSQL
            top_users = []
            for rank, user in enumerate(users, start=1):
                top_users.append(
                    LeaderboardUser(
                        rank=rank,
                        id=str(user.id),
                        name=user.full_name or "Unknown",
                        xp=user.total_xp or 0,
                        avatar=user.picture_url
                    )
                )
            
            # Get current user's rank
            my_rank = None
            if current_user_id:
                my_rank = await self._get_my_rank_from_postgres(
                    current_user_id, users
                )
            
            return LeaderboardResponse(
                top_users=top_users,
                my_rank=my_rank
            )
        
        # ... existing Redis logic ...
        
    except Exception as e:
        logger.error(f"❌ Error fetching leaderboard: {e}")
        # ✅ FALLBACK: If Redis fails, query from PostgreSQL
        return await self._get_leaderboard_from_postgres(limit, current_user_id)


async def _get_leaderboard_from_postgres(
    self,
    limit: int,
    current_user_id: Optional[str]
) -> LeaderboardResponse:
    """Fallback: Get leaderboard from PostgreSQL."""
    stmt = select(User).order_by(User.total_xp.desc()).limit(limit)
    result = await self.db.execute(stmt)
    users = result.scalars().all()
    
    top_users = []
    for rank, user in enumerate(users, start=1):
        top_users.append(
            LeaderboardUser(
                rank=rank,
                id=str(user.id),
                name=user.full_name or "Unknown",
                xp=user.total_xp or 0,
                avatar=user.picture_url
            )
        )
    
    my_rank = None
    if current_user_id:
        # Calculate rank from PostgreSQL
        stmt = select(func.count(User.id)).where(
            User.total_xp > select(User.total_xp).where(User.id == int(current_user_id))
        )
        result = await self.db.execute(stmt)
        rank_count = result.scalar() or 0
        my_rank = MyRank(rank=rank_count + 1, xp=...)
    
    return LeaderboardResponse(top_users=top_users, my_rank=my_rank)
```

---

### **4. Fix update_user_stats (single source of truth)**

```python
# scout_os_backend/app/modules/users/router.py

@router.put("/me/stats")
async def update_user_stats(
    request: UpdateUserStatsRequest = Body(...),
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Update current user's stats (XP, streak, and last_active_date)."""
    user_id = int(current_user.get("sub"))
    repository = AuthRepository(db)
    user = await repository.get_user_by_id(user_id)
    
    if not user:
        raise AppException(
            message="User not found",
            error_code="USER_NOT_FOUND",
            status_code=404
        )
    
    # ✅ Update PostgreSQL FIRST (source of truth)
    user.total_xp = request.total_xp
    user.streak = request.streak
    user.last_active_date = request.last_active_date or date.today()
    
    await db.commit()
    await db.refresh(user)
    
    # ✅ THEN update Redis cache (async, non-blocking)
    try:
        from app.modules.gamification.service import LeaderboardService
        leaderboard_service = LeaderboardService(db)
        await leaderboard_service.update_user_score(
            user_id=str(user_id),
            total_xp=request.total_xp
        )
    except Exception as e:
        # Don't fail the request if Redis update fails
        logger.warning(f"⚠️ Failed to update Redis leaderboard: {e}")
        # PostgreSQL is still updated, so request succeeds
    
    return success(
        data={
            "id": user.id,
            "total_xp": user.total_xp,
            "streak": user.streak,
            "last_active_date": user.last_active_date.isoformat() if user.last_active_date else None,
        },
        message="User stats updated successfully"
    )
```

---

## 📋 CHECKLIST PERBAIKAN

### **Priority 1 (Critical Bugs):**
- [ ] Fix hardcoded `user_id=1` di `submit_progress` endpoint
- [ ] Fix `submit_progress` untuk update `user.total_xp` sebelum update leaderboard
- [ ] Remove redundant PostgreSQL update dari `LeaderboardService.update_user_score`

### **Priority 2 (Architecture Issues):**
- [ ] Add fallback mechanism: Query PostgreSQL jika Redis kosong
- [ ] Ensure single source of truth: PostgreSQL sebagai primary, Redis sebagai cache
- [ ] Add error handling untuk Redis failures (jangan break request)

### **Priority 3 (Optimization):**
- [ ] Consider background job untuk sync Redis dari PostgreSQL
- [ ] Add monitoring untuk Redis connection health
- [ ] Consider using PostgreSQL window functions untuk rank calculation (fallback)

---

## 🧪 TESTING SCENARIOS

### **Test Case 1: User completes level**
1. User A completes Level 1 → XP = 15
2. Check `users.total_xp` → Should be 15
3. Check Redis `leaderboard:training` → Should have `{"1": 15}`
4. Check leaderboard API → User A should appear with 15 XP

### **Test Case 2: Multiple users**
1. User A completes Level 1 → XP = 15
2. User B completes Level 1 → XP = 15
3. Check leaderboard → Both users should appear
4. Check rank → Both should have rank 1 (tie)

### **Test Case 3: Redis down**
1. Stop Redis
2. User completes level → Should still update PostgreSQL
3. Check leaderboard API → Should fallback to PostgreSQL query
4. Leaderboard should still work (slower but functional)

### **Test Case 4: Redis empty**
1. Clear Redis `leaderboard:training`
2. Check leaderboard API → Should query PostgreSQL and populate Redis
3. Next request → Should use Redis (faster)

---

## 📝 SUMMARY

### **Root Causes:**
1. **Hardcoded user_id** → Semua progress untuk user_id=1
2. **XP tidak ter-update** → `submit_progress` tidak update `user.total_xp`
3. **Dual update path** → Tidak konsisten antara Flutter dan backend
4. **Redis sebagai source of truth** → Seharusnya PostgreSQL

### **Solutions:**
1. ✅ Use JWT authentication di `submit_progress`
2. ✅ Update `user.total_xp` sebelum update leaderboard
3. ✅ Single update path: `PUT /users/me/stats` sebagai primary
4. ✅ PostgreSQL sebagai source of truth, Redis sebagai cache
5. ✅ Fallback mechanism untuk Redis failures

---

**End of Report**
