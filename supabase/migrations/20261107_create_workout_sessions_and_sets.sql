-- ==============================================================================
-- Migration: 20261107_create_workout_sessions_and_sets.sql
-- Description: Tabel workout_sessions dan workout_sets di Supabase
-- Database: Supabase (PostgreSQL)
-- Safe & Idempotent: Bersifat mandiri & RLS terbuka untuk sinkronisasi
-- ==============================================================================

-- 1. Tabel workout_sessions (Sesi latihan selesai)
CREATE TABLE IF NOT EXISTS public.workout_sessions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL DEFAULT 'default_user',
    program_id TEXT NOT NULL,
    program_day_id INTEGER NOT NULL DEFAULT 1,
    program_title TEXT NOT NULL,
    scheduled_date TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    started_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER NOT NULL DEFAULT 0,
    calories_burned INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'completed',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_workout_sessions_user ON public.workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_started ON public.workout_sessions(started_at DESC);

ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all users to select workout_sessions" ON public.workout_sessions;
CREATE POLICY "Allow all users to select workout_sessions"
ON public.workout_sessions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all users to insert workout_sessions" ON public.workout_sessions;
CREATE POLICY "Allow all users to insert workout_sessions"
ON public.workout_sessions FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all users to update workout_sessions" ON public.workout_sessions;
CREATE POLICY "Allow all users to update workout_sessions"
ON public.workout_sessions FOR UPDATE USING (true);

-- 2. Tabel workout_sets (Detail repetisi & RIR per set)
CREATE TABLE IF NOT EXISTS public.workout_sets (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    exercise_id TEXT NOT NULL,
    set_number INTEGER NOT NULL,
    target_reps INTEGER,
    actual_reps INTEGER,
    target_load_kg NUMERIC,
    actual_load_kg NUMERIC,
    duration_seconds INTEGER,
    rir INTEGER DEFAULT 2,
    is_warmup BOOLEAN NOT NULL DEFAULT FALSE,
    form_score NUMERIC DEFAULT 1.0,
    data_source TEXT NOT NULL DEFAULT 'manual',
    status TEXT NOT NULL DEFAULT 'completed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_workout_sets_session ON public.workout_sets(session_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_exercise ON public.workout_sets(exercise_id);

ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all users to select workout_sets" ON public.workout_sets;
CREATE POLICY "Allow all users to select workout_sets"
ON public.workout_sets FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow all users to insert workout_sets" ON public.workout_sets;
CREATE POLICY "Allow all users to insert workout_sets"
ON public.workout_sets FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all users to update workout_sets" ON public.workout_sets;
CREATE POLICY "Allow all users to update workout_sets"
ON public.workout_sets FOR UPDATE USING (true);

