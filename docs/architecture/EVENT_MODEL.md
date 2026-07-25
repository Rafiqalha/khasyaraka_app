# Pradigi Event Model

Pradigi menggunakan arsitektur Event-Driven di mana setiap aktivitas di dalam platform direkam sebagai fakta bisnis yang kekal (*immutable business fact*).

## Struktur Event
Event diimplementasikan dengan struktur JSON berikut:

```json
{
  "id": "uuid-1234",
  "name": "mission.completed",
  "aggregate_type": "Mission",
  "aggregate_id": "mission-uuid",
  "payload": {
     // Objek JSON dinamis
  },
  "metadata": {
     "user_id": "uuid-9999",
     "request_id": "req-xyz",
     "trace_id": "trace-abc",
     "correlation_id": "corr-def",
     "causation_id": "cause-ghi",
     "source_engine": "MissionEngine"
  },
  "occurred_at": "2026-07-21T08:00:00Z",
  "schema_version": "v1"
}
```

## Prinsip Immutability
Setiap event yang telah disiarkan (*published*) tidak boleh diubah (immutable). Kesalahan data pada event dikoreksi dengan menerbitkan *compensating event*.
