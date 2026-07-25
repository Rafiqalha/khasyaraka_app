# ADR-004: Immutable Observation

## Status
Accepted

## Context
Di tahapan awal pembangunan model *machine learning*, hasil prediksi AI sering kali ditimpa secara langsung (*in-place update*) apabila dirasa tidak akurat atau diganti oleh algoritma yang lebih mutakhir keesokan harinya. Praktik ini menghapus pijakan konteks *mengapa* AI pernah mengambil keputusan di masa lalu.

## Decision
1. Entitas `Observation` (Asumsi Model AI) bersifat permanen dan imutabel (hanya `INSERT`, tanpa `UPDATE` atau `DELETE`).
2. Snapshot keadaan dunia saat AI mengambil kesimpulan dibekukan ke dalam `Observation Candidate`.
3. Kesalahan penalaran masa lalu tidak boleh dihapus, melainkan diselesaikan oleh entitas `Evidence Resolution` di tahap setelahnya, atau di-*replay* dengan `KnowledgeEpoch` baru tanpa menghancurkan rekam jejak lama.

## Consequences
- Memberikan Audit Trail Absolut (mirip perlakuan *commit* Git).
- Memungkinkan para _Data Scientist_ membandingkan keluaran model A dan model B di masa lalu secara retrospektif (karena datanya tetap diabadikan secara _read-only_).
