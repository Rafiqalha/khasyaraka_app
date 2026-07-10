DO $$ 
DECLARE 
    v_level_id VARCHAR(50);
BEGIN
    SELECT id INTO v_level_id FROM training_levels WHERE level_number = 1 LIMIT 1;
    
    IF v_level_id IS NOT NULL THEN
        INSERT INTO training_questions (
            id, level_id, type, question, payload, xp, ord
        ) VALUES (
            gen_random_uuid()::varchar,
            v_level_id,
            'cipher_rotor',
            'Pesan rahasia diterima! Putar roda sandi ke arah yang benar (Shift 3) untuk menemukan kode aslinya.',
            '{
                "encrypted_text": "KHOOR",
                "correct_shift": 3,
                "hint": "Geser roda sebanyak 3 angka ke depan."
            }'::jsonb,
            50,
            2
        );
    END IF;
END $$;
