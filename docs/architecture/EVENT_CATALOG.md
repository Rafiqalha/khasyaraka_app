# Pradigi Event Catalog

Katalog resmi seluruh event yang ada di dalam sistem Pradigi.

## 1. Capability Engine
- `capability.updated`: Diterbitkan ketika terdapat penyesuaian skor kemampuan pengguna (contoh: menyelesaikan mission, percakapan).
- `capability.decayed`: Diterbitkan ketika skor dikurangi secara logis karena tidak digunakan (Lazy Evaluation persistence).

## 2. Mission Engine
- `mission.started`: Diterbitkan ketika pengguna menerima misi baru.
- `mission.completed`: Diterbitkan ketika pengguna berhasil menuntaskan misi.

## 3. Workspace Engine
- `workspace.saved`: Diterbitkan ketika struktur kode atau file pengguna disimpan.

## 4. Roadmap Engine
- `roadmap.generated`: Diterbitkan ketika jalur belajar baru diracik oleh AI.

*(Katalog ini harus selalu diperbarui setiap kali engineer menambahkan event baru ke dalam `events/registry.go`)*
