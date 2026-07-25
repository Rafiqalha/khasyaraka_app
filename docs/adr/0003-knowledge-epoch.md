# ADR-003: Knowledge Epoch

## Status
Accepted

## Context
Seiring bertambahnya variabel di dalam sistem (versi Ontologi, formula Kalkulasi, batas minimal _Policy_ di _Governance_, dan jenis _Prompt LLM_), sistem kehilangan titik acuan terpadu. Menyimpan lima jenis *Foreign Key* pada tiap proses Replay rawan menimbulkan kombinasi *invalid* (misal menggunakan Ontologi v2 tapi dengan Formula v1).

## Decision
Sistem mendeklarasikan `Knowledge Epoch` sebagai "Satuan Hukum Alam" yang mengikat seluruh versi variabel tadi ke dalam satu payung entitas tunggal.
1. `KnowledgeEpoch` memiliki `Fingerprint` yang merupakan hasil *hash* matematis dari seluruh komponen internalnya.
2. `KnowledgeEpoch` adalah Imutabel (Tidak Menerima UPDATE). Setiap pergeseran 1 karakter pada _Prompt_ atau 1 batas ambang pada _Governance_ akan melahirkan *Epoch* baru.
3. Proses `Replay` akan ditautkan pada 1 *Epoch* murni untuk menjamin hasil turunan 100% identik di masa berapapun dieksekusi.

## Consequences
- Sangat menyederhanakan *debugging* dan audit. _Engineer_ cukup merujuk pada "Epoch 2026.1" untuk memutar ulang dunia.
- Membuka jalan terwujudnya fitur *Compatibility Matrix* agar komponen yang kedaluwarsa otomatis ditolak jika dipasangkan dengan komponen masa depan.
