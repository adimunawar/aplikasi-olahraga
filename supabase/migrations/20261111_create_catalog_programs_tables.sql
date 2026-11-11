-- ==============================================================================
-- Migration: 20261111_create_catalog_programs_tables.sql
-- Description: Tabel Master Catalog Program Latihan (Relasional 4 Tingkat)
-- Database: Supabase (PostgreSQL)
-- Kompatibel: Admin CMS Next.js 15 & Aplikasi Mobile Flutter
-- ==============================================================================

-- 1. TABEL: programs (Master Catalog Program)
CREATE TABLE IF NOT EXISTS public.programs (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    title JSONB DEFAULT '{"en": "Program", "id": "Program"}'::jsonb,
    description TEXT,
    category TEXT NOT NULL DEFAULT 'Muscle Building',
    level TEXT NOT NULL DEFAULT 'Beginner', -- 'Beginner', 'Intermediate', 'Advanced'
    duration_weeks INTEGER NOT NULL DEFAULT 8,
    training_days_per_week INTEGER NOT NULL DEFAULT 4,
    muscle_focus JSONB DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'Draft', -- 'Active', 'Draft', 'Inactive'
    is_published BOOLEAN NOT NULL DEFAULT false,
    featured BOOLEAN NOT NULL DEFAULT false,
    popular BOOLEAN NOT NULL DEFAULT false,
    thumbnail_url TEXT,
    banner_url TEXT,
    coach_pose_url TEXT,
    exercises_count INTEGER NOT NULL DEFAULT 0,
    schedule_data JSONB, -- JSON cache cadangan
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_programs_status ON public.programs(status);
CREATE INDEX IF NOT EXISTS idx_programs_published ON public.programs(is_published);
CREATE INDEX IF NOT EXISTS idx_programs_category ON public.programs(category);
CREATE INDEX IF NOT EXISTS idx_programs_created ON public.programs(created_at DESC);

-- 2. TABEL: program_weeks (Jadwal Minggu ke-N dalam Program)
CREATE TABLE IF NOT EXISTS public.program_weeks (
    id TEXT PRIMARY KEY,
    program_id TEXT NOT NULL REFERENCES public.programs(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL DEFAULT 1,
    title TEXT DEFAULT 'Foundation',
    focus_theme TEXT DEFAULT 'Foundation',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_program_weeks_program ON public.program_weeks(program_id);
CREATE INDEX IF NOT EXISTS idx_program_weeks_number ON public.program_weeks(program_id, week_number);

-- 3. TABEL: program_days (Hari Sesi Latihan & Rest Day)
CREATE TABLE IF NOT EXISTS public.program_days (
    id TEXT PRIMARY KEY,
    program_week_id TEXT NOT NULL REFERENCES public.program_weeks(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL DEFAULT 1, -- 1=Mon, 2=Tue, dst.
    day_of_week TEXT NOT NULL DEFAULT 'Mon', -- 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    type_code TEXT NOT NULL DEFAULT 'R', -- 'P'=Push, 'K'=Legs, 'C'=Core, 'F'=Full Body, 'R'=Rest
    title TEXT NOT NULL DEFAULT 'Workout Session', -- 'Upper Body A', 'Rest Day', dll.
    focus_en TEXT DEFAULT 'Workout',
    focus_id TEXT DEFAULT 'Latihan',
    is_rest BOOLEAN NOT NULL DEFAULT false,
    is_retest_milestone BOOLEAN NOT NULL DEFAULT false,
    estimated_duration_minutes INTEGER NOT NULL DEFAULT 30,
    thumbnail_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_program_days_week ON public.program_days(program_week_id);
CREATE INDEX IF NOT EXISTS idx_program_days_number ON public.program_days(program_week_id, day_number);

-- 4. TABEL: program_day_exercises (Daftar Gerakan / Exercise per Hari)
CREATE TABLE IF NOT EXISTS public.program_day_exercises (
    id TEXT PRIMARY KEY,
    program_day_id TEXT NOT NULL REFERENCES public.program_days(id) ON DELETE CASCADE,
    exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL DEFAULT 1,
    stage TEXT NOT NULL DEFAULT 'main', -- 'warmup', 'main', 'cooldown'
    sets INTEGER NOT NULL DEFAULT 3,
    reps INTEGER DEFAULT 12,
    duration_sec INTEGER,
    rest_seconds INTEGER NOT NULL DEFAULT 60,
    is_main BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_program_day_exercises_day ON public.program_day_exercises(program_day_id);
CREATE INDEX IF NOT EXISTS idx_program_day_exercises_exercise ON public.program_day_exercises(exercise_id);

-- ==============================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- A. programs
ALTER TABLE public.programs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to programs" ON public.programs;
CREATE POLICY "Allow public read access to programs"
ON public.programs FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow service and authenticated full access to programs" ON public.programs;
CREATE POLICY "Allow service and authenticated full access to programs"
ON public.programs FOR ALL USING (true) WITH CHECK (true);

-- B. program_weeks
ALTER TABLE public.program_weeks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to program_weeks" ON public.program_weeks;
CREATE POLICY "Allow public read access to program_weeks"
ON public.program_weeks FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow service and authenticated full access to program_weeks" ON public.program_weeks;
CREATE POLICY "Allow service and authenticated full access to program_weeks"
ON public.program_weeks FOR ALL USING (true) WITH CHECK (true);

-- C. program_days
ALTER TABLE public.program_days ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to program_days" ON public.program_days;
CREATE POLICY "Allow public read access to program_days"
ON public.program_days FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow service and authenticated full access to program_days" ON public.program_days;
CREATE POLICY "Allow service and authenticated full access to program_days"
ON public.program_days FOR ALL USING (true) WITH CHECK (true);

-- D. program_day_exercises
ALTER TABLE public.program_day_exercises ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to program_day_exercises" ON public.program_day_exercises;
CREATE POLICY "Allow public read access to program_day_exercises"
ON public.program_day_exercises FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow service and authenticated full access to program_day_exercises" ON public.program_day_exercises;
CREATE POLICY "Allow service and authenticated full access to program_day_exercises"
ON public.program_day_exercises FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- 6. TRIGGER AUTOMATIS: updated_at pada tabel programs
-- ==============================================================================
CREATE OR REPLACE FUNCTION update_programs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_programs_updated_at ON public.programs;
CREATE TRIGGER trigger_programs_updated_at
BEFORE UPDATE ON public.programs
FOR EACH ROW EXECUTE FUNCTION update_programs_updated_at();

