-- ==============================================================================
-- Migrasi Supabase: Tabel progression_decisions (Fase 4: Progression Engine)
-- Audit Log Keputusan Otak Coach / Progression Engine
-- Bersifat Mandiri (Stand-alone) & Bebas Dependency Constraint Foreign Key
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.progression_decisions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    exercise_id TEXT NOT NULL,
    decision TEXT NOT NULL, -- 'progress', 'maintain', 'regress', 'recover', 'reassess'
    previous_prescription TEXT, -- JSON snapshot resep lama
    next_prescription TEXT,     -- JSON snapshot resep baru
    reason TEXT NOT NULL,       -- Penjelasan transparan dari Coach Adi
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Indexing Cepat Kueri Rekomendasi
CREATE INDEX IF NOT EXISTS idx_progression_decisions_user ON public.progression_decisions(user_id, exercise_id);
CREATE INDEX IF NOT EXISTS idx_progression_decisions_created ON public.progression_decisions(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.progression_decisions ENABLE ROW LEVEL SECURITY;

-- Policies: Izinkan akses baca & tulis keputusan latihan
DROP POLICY IF EXISTS "Allow users to view progression decisions" ON public.progression_decisions;
CREATE POLICY "Allow users to view progression decisions"
ON public.progression_decisions FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow users to insert progression decisions" ON public.progression_decisions;
CREATE POLICY "Allow users to insert progression decisions"
ON public.progression_decisions FOR INSERT
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow users to update progression decisions" ON public.progression_decisions;
CREATE POLICY "Allow users to update progression decisions"
ON public.progression_decisions FOR UPDATE
USING (true);
