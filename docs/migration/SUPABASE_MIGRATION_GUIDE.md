# ✅ SUPABASE DATABASE MIGRATION GUIDE

## 📋 RINGKASAN

**Tujuan:** Migrate database connection dari Local PostgreSQL ke **Supabase** dengan SSL support.

**Supabase Connection String:**
```
postgresql://postgres.ngikvuvhqiabpuarrbev:rafiqalha29@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres
```

---

## 🔧 PERUBAHAN KODE

### **1. Update `app/core/config.py`**

**Perubahan:**
- ✅ Menambahkan support untuk `DATABASE_URL` langsung (Supabase full URL)
- ✅ Auto-convert `postgresql://` ke `postgresql+asyncpg://` untuk async driver
- ✅ Fallback ke individual components jika `DATABASE_URL` tidak ada

**Kode:**
```python
# Option 1: Use full DATABASE_URL (recommended for Supabase)
DATABASE_URL: Union[str, None] = None

# Option 2: Use individual components (fallback)
POSTGRES_SERVER: str = ""
POSTGRES_USER: str = ""
POSTGRES_PASSWORD: str = ""
POSTGRES_DB: str = ""
POSTGRES_PORT: int = 5432

@field_validator("SQLALCHEMY_DATABASE_URI", mode="before")
@classmethod
def assemble_db_connection(cls, v: str | None, info) -> AnyHttpUrl | str:
    # ✅ Priority 1: Use DATABASE_URL if provided (Supabase full URL)
    if isinstance(v, str):
        return v
    
    database_url = info.data.get("DATABASE_URL")
    if database_url:
        # ✅ Convert to asyncpg format if needed
        if database_url.startswith("postgresql://"):
            return database_url.replace("postgresql://", "postgresql+asyncpg://", 1)
        elif database_url.startswith("postgresql+asyncpg://"):
            return database_url
        else:
            return database_url
    
    # ✅ Priority 2: Build from individual components (fallback)
    return PostgresDsn.build(...)
```

---

### **2. Update `app/db/session.py`**

**Perubahan:**
- ✅ Menambahkan SSL configuration untuk Supabase
- ✅ Auto-detect Supabase URL dan enable SSL
- ✅ Support untuk SSL context dengan certificate verification

**Kode:**
```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
import ssl

# Check if URL already contains SSL parameters
database_url = str(settings.SQLALCHEMY_DATABASE_URI)
has_ssl_param = "sslmode=" in database_url or "ssl=" in database_url
is_supabase = "supabase" in database_url.lower()

# Prepare connect_args for SSL (only if needed)
connect_args = {}
if (is_supabase or settings.ENVIRONMENT == "production") and not has_ssl_param:
    ssl_context = ssl.create_default_context()
    ssl_context.check_hostname = False  # Supabase pooler uses different hostname
    ssl_context.verify_mode = ssl.CERT_NONE  # Disable cert verification for compatibility
    connect_args["ssl"] = ssl_context

engine = create_async_engine(
    settings.SQLALCHEMY_DATABASE_URI,
    echo=True,
    future=True,
    pool_pre_ping=True,
    connect_args=connect_args,  # ✅ SSL configuration for Supabase
)
```

---

## 📝 INSTRUKSI UPDATE `.env`

### **File: `scout_os_backend/.env`**

**✅ RECOMMENDED: Menggunakan DATABASE_URL (Full URL dari Supabase):**
```bash
# ✅ CRITICAL: Update DATABASE_URL dengan Supabase Transaction Pooler URL
DATABASE_URL=postgresql://postgres.ngikvuvhqiabpuarrbev:rafiqalha29@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres

# Optional: Environment setting (auto-enables SSL if production)
ENVIRONMENT=production

# Other settings...
SECRET_KEY=your_secret_key_here
```

**Alternative: Menggunakan Individual Components (Fallback):**
```bash
# If you prefer individual components (not recommended for Supabase)
POSTGRES_SERVER=aws-1-ap-southeast-2.pooler.supabase.com
POSTGRES_USER=postgres.ngikvuvhqiabpuarrbev
POSTGRES_PASSWORD=rafiqalha29
POSTGRES_DB=postgres
POSTGRES_PORT=6543
```

**Catatan Penting:**
- ✅ **Port 6543** adalah Supabase Transaction Pooler (recommended untuk production)
- ✅ **Port 5432** adalah Direct Connection (alternatif, tapi tidak recommended untuk production)
- ✅ SSL akan otomatis di-enable jika URL mengandung "supabase" atau `ENVIRONMENT=production`
- ✅ Password mungkin mengandung karakter khusus (`@`, `:`, dll) - pastikan di-escape dengan benar di URL

---

## 🚀 MIGRATION COMMANDS

### **1. Test Connection (Optional):**

```bash
cd scout_os_backend
python -c "
from app.core.config import settings
from app.db.session import engine
import asyncio

async def test():
    try:
        async with engine.connect() as conn:
            result = await conn.execute('SELECT version()')
            print('✅ Database connected:', result.scalar())
            print('✅ Database URL:', settings.SQLALCHEMY_DATABASE_URI[:50] + '...')
    except Exception as e:
        print('❌ Connection failed:', e)

asyncio.run(test())
"
```

### **2. Run Alembic Migrations:**

```bash
cd scout_os_backend

# ✅ CRITICAL: Run migrations to create all tables
alembic upgrade head
```

**Expected Output:**
```
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> <revision_id>, <migration_name>
...
INFO  [alembic.runtime.migration] Running upgrade <previous_revision> -> <latest_revision>, <migration_name>
```

### **3. Verify Tables Created:**

```bash
cd scout_os_backend
python -c "
from app.core.config import settings
from app.db.session import engine
from sqlalchemy import inspect, text
import asyncio

async def verify():
    try:
        async with engine.connect() as conn:
            # Get table names
            result = await conn.execute(text(\"\"\"
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            \"\"\"))
            tables = [row[0] for row in result]
            print(f'✅ Tables created: {len(tables)}')
            for table in tables:
                print(f'   - {table}')
    except Exception as e:
        print('❌ Verification failed:', e)

asyncio.run(verify())
"
```

---

## 🔍 TROUBLESHOOTING

### **Error: SSL connection required**

**Problem:** Supabase requires SSL, but connection is not using SSL.

**Solution:**
1. Pastikan URL mengandung "supabase" (akan auto-enable SSL)
2. Atau tambahkan `?sslmode=require` ke URL
3. Atau set `ENVIRONMENT=production` di `.env`
4. Check `app/db/session.py` - pastikan `connect_args` di-set dengan SSL context

### **Error: SSL certificate verification failed**

**Problem:** SSL certificate tidak bisa diverifikasi.

**Solution:**
- Code sudah menggunakan `ssl_context.verify_mode = ssl.CERT_NONE` untuk Supabase
- Jika masih error, pastikan URL benar dan port 6543 (Transaction Pooler)
- Alternative: Tambahkan `?sslmode=require` ke URL (asyncpg akan handle SSL)

### **Error: Connection timeout**

**Problem:** Tidak bisa connect ke Supabase.

**Solution:**
1. Pastikan IP address di-whitelist di Supabase Dashboard (Settings → Database → Connection Pooling)
2. Pastikan menggunakan port **6543** (Transaction Pooler) bukan 5432
3. Check firewall/network settings
4. Verify hostname: `aws-1-ap-southeast-2.pooler.supabase.com`

### **Error: Authentication failed**

**Problem:** Username/password salah.

**Solution:**
1. Pastikan `DATABASE_URL` atau credentials di `.env` benar
2. Pastikan password tidak mengandung karakter khusus yang perlu di-encode
3. Check Supabase Dashboard untuk verify credentials
4. Pastikan username format: `postgres.ngikvuvhqiabpuarrbev` (dengan dot)

### **Error: asyncpg SSL parameter**

**Problem:** `ssl` parameter tidak dikenali oleh asyncpg.

**Solution:**
- Pastikan menggunakan `ssl.create_default_context()` bukan string
- Atau gunakan URL parameter: `?sslmode=require`
- Check asyncpg version: `pip show asyncpg`

---

## ✅ VERIFIKASI SETELAH MIGRATION

### **Checklist:**

- [ ] ✅ `.env` file updated dengan `DATABASE_URL` atau individual components
- [ ] ✅ SSL configuration di `app/db/session.py` sudah benar
- [ ] ✅ Test connection berhasil
- [ ] ✅ `alembic upgrade head` berhasil
- [ ] ✅ Semua tables ter-create di Supabase
- [ ] ✅ Backend bisa connect dan query database
- [ ] ✅ Flutter app masih bisa connect ke backend

---

## 📊 SUPABASE CONNECTION DETAILS

**Transaction Pooler (Recommended):**
- **Host:** `aws-1-ap-southeast-2.pooler.supabase.com`
- **Port:** `6543`
- **URL Format:** `postgresql://user:pass@host:6543/db`
- **SSL:** ✅ Required (auto-enabled)

**Direct Connection (Alternative):**
- **Host:** `aws-1-ap-southeast-2.pooler.supabase.com` (atau direct host)
- **Port:** `5432`
- **URL Format:** `postgresql://user:pass@host:5432/db`
- **SSL:** ✅ Required

**SSL Configuration:**
- ✅ **Required** untuk semua connections
- ✅ Auto-enabled jika URL mengandung "supabase"
- ✅ Certificate verification: Disabled (CERT_NONE) untuk compatibility dengan Supabase pooler
- ✅ Hostname verification: Disabled untuk compatibility

---

## 🎯 HASIL AKHIR

**Sebelum:**
- Database: Local PostgreSQL
- Connection: `postgresql+asyncpg://user:pass@localhost:5432/db`
- SSL: Tidak diperlukan

**Sesudah:**
- Database: Supabase (Managed PostgreSQL)
- Connection: `postgresql+asyncpg://user:pass@supabase-host:6543/db`
- SSL: ✅ Required dan auto-enabled
- Production-ready: ✅ Transaction Pooler dengan SSL

---

## 📝 CONTOH `.env` FILE

```bash
# ✅ SUPABASE DATABASE CONNECTION
DATABASE_URL=postgresql://postgres.ngikvuvhqiabpuarrbev:rafiqalha29@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres

# Environment
ENVIRONMENT=production

# Security
SECRET_KEY=your_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# Redis (if using Supabase Redis or separate Redis instance)
REDIS_HOST=your_redis_host
REDIS_PORT=6379

# CORS
BACKEND_CORS_ORIGINS=["http://localhost:8080","https://yourdomain.com"]
```

---

**END OF SUPABASE MIGRATION GUIDE**
