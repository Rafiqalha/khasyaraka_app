#!/bin/bash
# ==========================================================================
#  Pradigi — Seed 300 Test Users for WebSocket Stress Testing
# ==========================================================================
#  Usage:  bash infra/seed_test_users.sh
#  Requires: psql client, database running on localhost:5433
# ==========================================================================

DB_URL="${DATABASE_URL:-postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable}"
echo "Seeding test users into $DB_URL..."

for i in $(seq 1 300); do
  EMAIL="stress_test_user${i}@pradigi.test"
  psql "$DB_URL" -c "
    INSERT INTO users (email, hashed_password, full_name, is_active, country_id, location_set, total_xp)
    VALUES ('$EMAIL', '\$2a\$10\$dummyhashplaceholder', 'Stress Test User $i', TRUE, 'ID', TRUE, ${i}00)
    ON CONFLICT (email) DO NOTHING;
  " 2>/dev/null
done

echo "Done. 300 test users seeded (email: stress_test_user1@ ... stress_test_user300@)"
echo ""
echo "Now run the stress test:"
echo "  k6 run infra/websocket_stress_test.js"
echo ""
echo "Custom parameters:"
echo "  k6 run -e API_HOST=your-ip:8081 -e TEST_DURATION=120s infra/websocket_stress_test.js"
