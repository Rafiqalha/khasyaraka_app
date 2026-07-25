# ADR-001: Projection is Cache

## Status
Accepted

## Context
Dalam membangun sistem kapabilitas pembelajaran, terdapat kecenderungan untuk menyimpan "skor" akhir (*Score*) dari seorang pengguna sebagai kolom tunggal (misal `users.score`). Namun, perhitungan kapabilitas adalah komputasi kompleks yang melibatkan faktor waktu, bobot, kepercayaan, dan grafik penyebaran (DAG). 

Jika *Score* diperlakukan sebagai kebenaran (*Source of Truth*), maka sistem kehilangan kemampuan untuk mengaudit atau mengubah rumus kapabilitas di kemudian hari tanpa merusak data historis pengguna.

## Decision
Sistem menetapkan bahwa:
1. **Competency Projection hanyalah sekadar materialisasi (Cache).**
2. Sumber Kebenaran Sejati (*Source of Truth*) berada pada `Competency Contribution` (turunan langsung dari `Evidence`).
3. Seluruh *Projection* memiliki masa kadaluarsa (`ExpiresAt`) dan dapat dihancurkan kapan saja untuk dihitung ulang secara gratis (*Zero-cost Rebuild*).

## Consequences
- Keuntungan: Kita dapat melakukan perhitungan ulang (Replay) secara absolut jika ditemukan *bug* pada _Decay Engine_ atau *Propagation Strategy* tanpa kehilangan histori belajar.
- Kerugian: _Read latency_ berpotensi tinggi jika sistem harus merajut grafik dari awal setiap kali skor di-akses. Ini diatasi dengan adanya `Projection Scheduler` untuk melakukan rekalkulasi secara asinkron di _background_.
