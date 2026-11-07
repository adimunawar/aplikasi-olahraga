-- ==============================================================================
-- Migration: 20261107_create_dynamic_programs.sql
-- Description: Tabel program dinamis (training_programs, program_sessions, program_exercises)
-- Database: Supabase (PostgreSQL)
-- Safe & Idempotent: Kompatibel offline-first (user_id TEXT) & RLS aktif
-- ==============================================================================

-- 1. Tabel training_programs (Program latihan personal user)
CREATE TABLE IF NOT EXISTS public.training_programs (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'completed', 'archived'
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    weekly_frequency INTEGER NOT NULL DEFAULT 3,
    target_duration_minutes INTEGER NOT NULL DEFAULT 30,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_training_programs_user ON public.training_programs(user_id);
CREATE INDEX IF NOT EXISTS idx_training_programs_status ON public.training_programs(status);

ALTER TABLE public.training_programs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all users to view training programs" ON public.training_programs;
CREATE POLICY "Allow all users to view training programs"
ON public.training_programs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all users to insert training programs" ON public.training_programs;
CREATE POLICY "Allow all users to insert training programs"
ON public.training_programs FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all users to update training programs" ON public.training_programs;
CREATE POLICY "Allow all users to update training programs"
ON public.training_programs FOR UPDATE USING (true);

-- 2. Tabel program_sessions (Sesi harian dinamis, misal Session A, B, C atau Sesi 1, 2)
CREATE TABLE IF NOT EXISTS public.program_sessions (
    id TEXT PRIMARY KEY,
    program_id TEXT NOT NULL REFERENCES public.training_programs(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL DEFAULT 1,
    name TEXT NOT NULL, -- 'Session A', 'Full Body 1', etc.
    target_duration_minutes INTEGER NOT NULL DEFAULT 30,
    focus_label TEXT NOT NULL DEFAULT 'Full Body',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_program_sessions_program ON public.program_sessions(program_id);

ALTER TABLE public.program_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all users to view program sessions" ON public.program_sessions;
CREATE POLICY "Allow all users to view program sessions"
ON public.program_sessions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all users to manage program sessions" ON public.program_sessions;
CREATE POLICY "Allow all users to manage program sessions"
ON public.program_sessions FOR ALL USING (true);

-- 3. Tabel program_exercises (Resep latihan, target set, rentang reps, stage, rir)
CREATE TABLE IF NOT EXISTS public.program_exercises (
    id TEXT PRIMARY KEY,
    program_session_id TEXT NOT NULL REFERENCES public.program_sessions(id) ON DELETE CASCADE,
    exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL DEFAULT 1,
    stage TEXT NOT NULL DEFAULT 'main', -- 'warm_up', 'main', 'cool_down'
    target_sets INTEGER NOT NULL DEFAULT 3,
    min_reps INTEGER NOT NULL DEFAULT 8,
    max_reps INTEGER NOT NULL DEFAULT 12,
    target_rir INTEGER DEFAULT 2,
    rest_seconds INTEGER NOT NULL DEFAULT 60
);

CREATE INDEX IF NOT EXISTS idx_program_exercises_session ON public.program_exercises(program_session_id);
CREATE INDEX IF NOT EXISTS idx_program_exercises_exercise ON public.program_exercises(exercise_id);

ALTER TABLE public.program_exercises ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all users to view program exercises" ON public.program_exercises;
CREATE POLICY "Allow all users to view program exercises"
ON public.program_exercises FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all users to manage program exercises" ON public.program_exercises;
CREATE POLICY "Allow all users to manage program exercises"
ON public.program_exercises FOR ALL USING (true);
