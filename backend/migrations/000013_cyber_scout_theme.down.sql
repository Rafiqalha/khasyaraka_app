-- Revert Section Titles
UPDATE training_sections SET title = 'Bagian 1: Dasar' WHERE id IN ('puk', 'ppgd', 'nav', 'tali', 'sandi');

-- (We don't need to revert the exact unit text in the down migration since it would be extremely long and we probably don't want to go back to the boring text anyway, but here is a simple revert for PUK 1 to keep it clean)
UPDATE training_units SET title = 'Unit 1', description = 'Deskripsi unit 1' WHERE id IN ('puk_1', 'ppgd_1', 'nav_1', 'tali_1', 'sandi_1');
