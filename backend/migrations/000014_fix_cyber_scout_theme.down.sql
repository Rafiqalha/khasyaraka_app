-- Revert PUK Units
UPDATE training_units SET title = 'Unit 1', description = 'Deskripsi unit 1' WHERE id IN ('puk_u1', 'ppgd_u1', 'nav_u1', 'tali_u1', 'sandi_u1');
