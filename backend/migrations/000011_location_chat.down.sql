DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS chat_rooms;

ALTER TABLE users 
DROP COLUMN IF EXISTS kecamatan_id,
DROP COLUMN IF EXISTS kabupaten_id,
DROP COLUMN IF EXISTS provinsi_id,
DROP COLUMN IF EXISTS location_set;
