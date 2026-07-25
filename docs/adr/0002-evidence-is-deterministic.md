# ADR-002: Evidence is Deterministic

## Status
Accepted

## Context
Di masa lalu, *Evidence* dihasilkan dari mesin ekstraksi AI yang probabilistik (misalnya LLM), menyebabkan rentan terhadap halusinasi dan variasi format antar-generasi model (GPT-4 vs Gemini). Jika model LLM diganti, *Evidence* yang dihasilkan bisa berbeda untuk peristiwa (*Learning Activity*) yang persis sama.

## Decision
Sistem harus menjamin:
1. Pengekstrakan *Evidence* murni bersifat deterministik dan dikontrol oleh `Governance Policies` serta `Rules`.
2. Setiap konflik antar-*Evidence* tidak boleh menimpa (Overwrite) data lama. Semua konflik diselesaikan lewat pembuatan entitas turunan (Resolusi Konflik Imutabel).
3. Bukti yang lolos memiliki jaminan 100% konsistensi struktural terhadap `Skill Ontology`.

## Consequences
- *Reasoning Pipeline* terbelah menjadi dua: Fase probabilistik murni (`Observation`) dan fase deterministik pengunci fakta (`Evidence`).
- Kita bisa menolak luaran model AI manapun di dunia jika tidak memenuhi skema kebenaran internal Pradigi.
