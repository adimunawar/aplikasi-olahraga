-- ==============================================================================
-- Migration: 20261113_secure_rls_and_owner_isolation.sql
-- Description: Remediasi Keamanan Supabase (Prioritas P0 Audit):
--   1. Cabut hak akses publik (anon write) pada seluruh tabel data personal pengguna
--   2. Hapus seluruh policy lama yang longgar "USING (true); WITH CHECK (true);"
--   3. Terapkan Row Level Security (RLS) ketat berbasis kepemilikan auth.uid()
--   4. Pertahankan katalog latihan & katalog program sebagai Public Read-Only
-- Database: Supabase (PostgreSQL)
-- Schema Exact Match:
--   - public.users: kolom 'id' (user id)
--   - public.user_profiles: kolom 'id' (user id)
--   - public.workout_sessions: kolom 'user_id'
--   - public.workout_sets: relasi via session_id -> workout_sessions.id
--   - public.progression_decisions: kolom 'user_id'
--   - public.training_programs: kolom 'user_id'
--   - public.program_sessions: relasi via program_id -> training_programs.id
--   - public.program_exercises: relasi via program_session_id -> program_sessions.id
--   - public.exercises, public.programs, public.program_weeks, public.program_days,
--     public.program_day_exercises: CMS Master Catalog (Read-Only Publik)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. AMANKAN TABEL USERS & USER_PROFILES (Kolom identifier: 'id')
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Cabut grants tulis berlebih dari role anon pada tabel personal
REVOKE INSERT, UPDATE, DELETE ON TABLE public.users FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.user_profiles FROM anon;

-- Hapus policy lama pada public.users
DROP POLICY IF EXISTS "Users can view their own record" ON public.users;
DROP POLICY IF EXISTS "Users can update their own record" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own record" ON public.users;
DROP POLICY IF EXISTS "Allow all users full access to users" ON public.users;
DROP POLICY IF EXISTS "Users can only view their own user record" ON public.users;
DROP POLICY IF EXISTS "Users can only update their own user record" ON public.users;
DROP POLICY IF EXISTS "Users can only insert their own user record" ON public.users;

-- Terapkan policy RLS ketat pada public.users
CREATE POLICY "Users can only view their own user record"
ON public.users FOR SELECT TO authenticated
USING ((auth.uid())::text = id::text);

CREATE POLICY "Users can only update their own user record"
ON public.users FOR UPDATE TO authenticated
USING ((auth.uid())::text = id::text)
WITH CHECK ((auth.uid())::text = id::text);

CREATE POLICY "Users can only insert their own user record"
ON public.users FOR INSERT TO authenticated
WITH CHECK ((auth.uid())::text = id::text);

-- Hapus policy lama pada public.user_profiles
DROP POLICY IF EXISTS "Allow users to view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Allow users to insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Allow users to update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Allow all users to select profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Allow all users to insert profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Allow all users to update profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.user_profiles;

-- Terapkan policy RLS ketat pada public.user_profiles (identifier profil adalah 'id')
CREATE POLICY "Users can view own profile"
ON public.user_profiles FOR SELECT TO authenticated
USING ((auth.uid())::text = id::text);

CREATE POLICY "Users can insert own profile"
ON public.user_profiles FOR INSERT TO authenticated
WITH CHECK ((auth.uid())::text = id::text);

CREATE POLICY "Users can update own profile"
ON public.user_profiles FOR UPDATE TO authenticated
USING ((auth.uid())::text = id::text)
WITH CHECK ((auth.uid())::text = id::text);

CREATE POLICY "Users can delete own profile"
ON public.user_profiles FOR DELETE TO authenticated
USING ((auth.uid())::text = id::text);

-- ------------------------------------------------------------------------------
-- 2. AMANKAN TABEL WORKOUT_SESSIONS & WORKOUT_SETS
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.workout_sets ENABLE ROW LEVEL SECURITY;

REVOKE INSERT, UPDATE, DELETE ON TABLE public.workout_sessions FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.workout_sets FROM anon;

-- Hapus policy lama pada public.workout_sessions
DROP POLICY IF EXISTS "Allow all users to select workout_sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Allow all users to insert workout_sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Allow all users to update workout_sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Allow all users to delete workout_sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Users can view own workout sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Users can insert own workout sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Users can update own workout sessions" ON public.workout_sessions;
DROP POLICY IF EXISTS "Users can delete own workout sessions" ON public.workout_sessions;

-- Terapkan policy RLS ketat pada public.workout_sessions (kolom 'user_id')
CREATE POLICY "Users can view own workout sessions"
ON public.workout_sessions FOR SELECT TO authenticated
USING ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can insert own workout sessions"
ON public.workout_sessions FOR INSERT TO authenticated
WITH CHECK ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can update own workout sessions"
ON public.workout_sessions FOR UPDATE TO authenticated
USING ((auth.uid())::text = user_id::text)
WITH CHECK ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can delete own workout sessions"
ON public.workout_sessions FOR DELETE TO authenticated
USING ((auth.uid())::text = user_id::text);

-- Hapus policy lama pada public.workout_sets
DROP POLICY IF EXISTS "Allow all users to select workout_sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Allow all users to insert workout_sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Allow all users to update workout_sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Allow all users to delete workout_sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can view own workout sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can insert own workout sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can update own workout sets" ON public.workout_sets;
DROP POLICY IF EXISTS "Users can delete own workout sets" ON public.workout_sets;

-- Terapkan policy RLS ketat pada public.workout_sets (Relasi ke session milik user)
CREATE POLICY "Users can view own workout sets"
ON public.workout_sets FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.workout_sessions ws
        WHERE ws.id::text = workout_sets.session_id::text AND ws.user_id::text = (auth.uid())::text
    )
);

CREATE POLICY "Users can insert own workout sets"
ON public.workout_sets FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.workout_sessions ws
        WHERE ws.id::text = workout_sets.session_id::text AND ws.user_id::text = (auth.uid())::text
    )
);

CREATE POLICY "Users can update own workout sets"
ON public.workout_sets FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.workout_sessions ws
        WHERE ws.id::text = workout_sets.session_id::text AND ws.user_id::text = (auth.uid())::text
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.workout_sessions ws
        WHERE ws.id::text = workout_sets.session_id::text AND ws.user_id::text = (auth.uid())::text
    )
);

CREATE POLICY "Users can delete own workout sets"
ON public.workout_sets FOR DELETE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.workout_sessions ws
        WHERE ws.id::text = workout_sets.session_id::text AND ws.user_id::text = (auth.uid())::text
    )
);

-- ------------------------------------------------------------------------------
-- 3. AMANKAN TABEL PROGRESSION_DECISIONS
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.progression_decisions ENABLE ROW LEVEL SECURITY;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.progression_decisions FROM anon;

DROP POLICY IF EXISTS "Allow users to view progression decisions" ON public.progression_decisions;
DROP POLICY IF EXISTS "Allow users to insert progression decisions" ON public.progression_decisions;
DROP POLICY IF EXISTS "Allow users to update progression decisions" ON public.progression_decisions;
DROP POLICY IF EXISTS "Users can view own progression decisions" ON public.progression_decisions;
DROP POLICY IF EXISTS "Users can insert own progression decisions" ON public.progression_decisions;
DROP POLICY IF EXISTS "Users can update own progression decisions" ON public.progression_decisions;

CREATE POLICY "Users can view own progression decisions"
ON public.progression_decisions FOR SELECT TO authenticated
USING ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can insert own progression decisions"
ON public.progression_decisions FOR INSERT TO authenticated
WITH CHECK ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can update own progression decisions"
ON public.progression_decisions FOR UPDATE TO authenticated
USING ((auth.uid())::text = user_id::text)
WITH CHECK ((auth.uid())::text = user_id::text);

-- ------------------------------------------------------------------------------
-- 4. AMANKAN TABEL DYNAMIC PROGRAMS (training_programs, program_sessions, program_exercises)
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.training_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.program_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.program_exercises ENABLE ROW LEVEL SECURITY;

REVOKE INSERT, UPDATE, DELETE ON TABLE public.training_programs FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.program_sessions FROM anon;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.program_exercises FROM anon;

DROP POLICY IF EXISTS "Allow all users to view training programs" ON public.training_programs;
DROP POLICY IF EXISTS "Allow all users to insert training programs" ON public.training_programs;
DROP POLICY IF EXISTS "Allow all users to update training programs" ON public.training_programs;
DROP POLICY IF EXISTS "Users can view own training programs" ON public.training_programs;
DROP POLICY IF EXISTS "Users can insert own training programs" ON public.training_programs;
DROP POLICY IF EXISTS "Users can update own training programs" ON public.training_programs;
DROP POLICY IF EXISTS "Users can delete own training programs" ON public.training_programs;

DROP POLICY IF EXISTS "Allow all users to view program sessions" ON public.program_sessions;
DROP POLICY IF EXISTS "Allow all users to manage program sessions" ON public.program_sessions;
DROP POLICY IF EXISTS "Users can view own program sessions" ON public.program_sessions;
DROP POLICY IF EXISTS "Users can manage own program sessions" ON public.program_sessions;

DROP POLICY IF EXISTS "Allow all users to view program exercises" ON public.program_exercises;
DROP POLICY IF EXISTS "Allow all users to manage program exercises" ON public.program_exercises;
DROP POLICY IF EXISTS "Users can view own program exercises" ON public.program_exercises;
DROP POLICY IF EXISTS "Users can manage own program exercises" ON public.program_exercises;

-- Training Programs RLS (kolom 'user_id')
CREATE POLICY "Users can view own training programs"
ON public.training_programs FOR SELECT TO authenticated
USING ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can insert own training programs"
ON public.training_programs FOR INSERT TO authenticated
WITH CHECK ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can update own training programs"
ON public.training_programs FOR UPDATE TO authenticated
USING ((auth.uid())::text = user_id::text)
WITH CHECK ((auth.uid())::text = user_id::text);

CREATE POLICY "Users can delete own training programs"
ON public.training_programs FOR DELETE TO authenticated
USING ((auth.uid())::text = user_id::text);

-- Program Sessions RLS (Relasi ke training_programs milik user)
CREATE POLICY "Users can view own program sessions"
ON public.program_sessions FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.training_programs tp
        WHERE tp.id::text = program_sessions.program_id::text AND tp.user_id::text = (auth.uid())::text
    )
);

CREATE POLICY "Users can manage own program sessions"
ON public.program_sessions FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.training_programs tp
        WHERE tp.id::text = program_sessions.program_id::text AND tp.user_id::text = (auth.uid())::text
    )
);

-- Program Exercises RLS (Relasi hierarki ke training_programs milik user)
CREATE POLICY "Users can view own program exercises"
ON public.program_exercises FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.program_sessions ps
        JOIN public.training_programs tp ON tp.id::text = ps.program_id::text
        WHERE ps.id::text = program_exercises.program_session_id::text AND tp.user_id::text = (auth.uid())::text
    )
);

CREATE POLICY "Users can manage own program exercises"
ON public.program_exercises FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.program_sessions ps
        JOIN public.training_programs tp ON tp.id::text = ps.program_id::text
        WHERE ps.id::text = program_exercises.program_session_id::text AND tp.user_id::text = (auth.uid())::text
    )
);

-- ------------------------------------------------------------------------------
-- 5. PASTIKAN KATALOG CMS PUBLIK BERSIFAT READ-ONLY UNTUK PUBLIK
-- ------------------------------------------------------------------------------
ALTER TABLE IF EXISTS public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.program_weeks ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.program_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.program_day_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.catalog_programs ENABLE ROW LEVEL SECURITY;

-- Izinkan publik (anon & authenticated) HANYA untuk membaca katalog
GRANT SELECT ON TABLE public.exercises TO anon, authenticated;
GRANT SELECT ON TABLE public.programs TO anon, authenticated;
GRANT SELECT ON TABLE public.program_weeks TO anon, authenticated;
GRANT SELECT ON TABLE public.program_days TO anon, authenticated;
GRANT SELECT ON TABLE public.program_day_exercises TO anon, authenticated;

-- Pastikan anon dan authenticated TIDAK BISA mengubah data katalog
REVOKE INSERT, UPDATE, DELETE ON TABLE public.exercises FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.programs FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.program_weeks FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.program_days FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON TABLE public.program_day_exercises FROM anon, authenticated;

DROP POLICY IF EXISTS "Allow public read-only access to exercises" ON public.exercises;
CREATE POLICY "Allow public read-only access to exercises"
ON public.exercises FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public read-only access to programs" ON public.programs;
CREATE POLICY "Allow public read-only access to programs"
ON public.programs FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public read-only access to program_weeks" ON public.program_weeks;
CREATE POLICY "Allow public read-only access to program_weeks"
ON public.program_weeks FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public read-only access to program_days" ON public.program_days;
CREATE POLICY "Allow public read-only access to program_days"
ON public.program_days FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Allow public read-only access to program_day_exercises" ON public.program_day_exercises;
CREATE POLICY "Allow public read-only access to program_day_exercises"
ON public.program_day_exercises FOR SELECT
USING (true);



