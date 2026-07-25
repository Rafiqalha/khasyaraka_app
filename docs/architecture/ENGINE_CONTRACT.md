# Pradigi Engine Contracts

Pradigi membagi sistemnya menjadi unit-unit logis yang disebut **Engine**. Aturan utama arsitektur ini adalah **Decoupling**.

## Aturan Emas
1. Engine **TIDAK BOLEH** memanggil API internal (function call langsung) ke Engine lain (kecuali Utility/Gateway).
2. Engine **HARUS** berkomunikasi lewat **Event Engine**.
3. *Event* yang disiarkan harus menjadi kontrak tetap (*schema versioning*).

## Topologi Kontrak Saat Ini
- **Identity Engine**: Menyediakan kebenaran absolut mengenai profil pengguna. Mengonsumsi nol event.
- **Capability Engine**: Memproduksi (Publish) `capability.updated`. Mengonsumsi event dari *Mission Engine* dan *Workspace Engine* (via `SubmitEvent`).
- **Memory Engine (Mendatang)**: Akan mengonsumsi hampir semua event dari ekosistem Pradigi (`mission.*`, `capability.*`, `workspace.*`) untuk meracik konteks *Long-Term Memory*.

*(Dokumentasi ini dijaga seiring bertambahnya jumlah Engine)*
