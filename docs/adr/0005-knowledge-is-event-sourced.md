# ADR-005: Knowledge is Event-Sourced

## Status
Accepted

## Context
Pendekatan tradisional dalam membangun sistem profil pembelajaran, kecerdasan buatan, maupun memori kognitif sering kali terpaku pada operasi pembaruan (*in-place updates*, CRUD) ke dalam basis data statis (misal: `UPDATE user_skills SET level = 5`). Seiring bertambahnya kerumitan model (*AI Reasoning*), mengubah fakta secara *in-place* akan menimbun utang teknis yang mustahil diurai: kehilangan jejak *mengapa* nilai itu berubah, ketidakmampuan kembali ke masa lalu (*time-travel*), dan hilangnya auditibilitas saat sistem berpindah ke algoritma baru.

## Decision
Sistem Pradigi meresmikan filosofi **Event-Sourced Knowledge Representation** sebagai tulang punggung arsitektur v1.0, dengan ketentuan:
1. Segala perhitungan yang dikonsumsi oleh lapisan *Intelligence* (Capability, Memory) **bukanlah Source of Truth**, melainkan tembolok (*Projection Cache*).
2. *Source of Truth* adalah kejadian (*Events*) imutabel (contoh: `CompetencyContribution`, `MemoryEvent`) yang murni ditambahkan (*append-only*), tak pernah dihapus atau diubah.
3. Seluruh *Projection Cache* dapat dan boleh dihancurkan seutuhnya kapan saja, lalu dirajut ulang secara gratis dari awal (melalui `Replay`) menggunakan hukum alam mutlak yang diabadikan dalam `KnowledgeEpoch`.

## Consequences
- Membawa *reliability* tingkat militer ke dalam platform *Reasoning AI*.
- Mengorbankan *overhead* komputasi asinkron (dibutuhkan `Scheduler` khusus untuk komputasi DAG), namun menebusnya dengan kepastian reproduktibilitas 100% dan terwujudnya *Explainable AI* yang dapat merunut sebab-akibat hingga lapis interaksi pengguna paling awal (*Knowledge Lineage*).
