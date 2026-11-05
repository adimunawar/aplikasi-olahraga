-- ==============================================================================
-- Migration: 20261106_create_exercises_table.sql
-- Description: Master catalog and custom exercises table with warm-up & offline sync support
-- Database: Supabase (PostgreSQL)
-- Safe & Idempotent: Can be run on new or pre-existing databases safely
-- ==============================================================================

-- 1. Enable pgcrypto extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Create exercises table if not exists (base structure)
CREATE TABLE IF NOT EXISTS public.exercises (
    id TEXT PRIMARY KEY
);

-- 3. Ensure all columns exist (adds missing columns if table already existed previously)
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS name_id TEXT NOT NULL DEFAULT '';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS name_en TEXT NOT NULL DEFAULT '';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT 'push';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS stage TEXT NOT NULL DEFAULT 'main'; -- 'warmup', 'main', 'cooldown'
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS difficulty TEXT NOT NULL DEFAULT 'intermediate';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS tracking_type TEXT NOT NULL DEFAULT 'reps';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS primary_muscles JSONB NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS stabilizer_muscles JSONB NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS steps_id JSONB NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS steps_en JSONB NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS common_mistakes_id JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS common_mistakes_en JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS breathing_tips_id TEXT;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS breathing_tips_en TEXT;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS start_pose_asset TEXT;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS end_pose_asset TEXT;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS animation_asset TEXT;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS video_url TEXT;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS is_custom BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS created_by_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());

-- 4. Create high-performance indexes for search, filtering, and warm-up queries
CREATE INDEX IF NOT EXISTS idx_exercises_category ON public.exercises(category);
CREATE INDEX IF NOT EXISTS idx_exercises_stage ON public.exercises(stage);
CREATE INDEX IF NOT EXISTS idx_exercises_difficulty ON public.exercises(difficulty);
CREATE INDEX IF NOT EXISTS idx_exercises_is_custom ON public.exercises(is_custom);
CREATE INDEX IF NOT EXISTS idx_exercises_created_by ON public.exercises(created_by_user_id);
CREATE INDEX IF NOT EXISTS idx_exercises_primary_muscles ON public.exercises USING GIN (primary_muscles);

-- 5. Enable Row Level Security (RLS)
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

-- 6. Safe Policies (Drop first then re-create to prevent "already exists" errors)
DROP POLICY IF EXISTS "Public can view standard exercises" ON public.exercises;
CREATE POLICY "Public can view standard exercises"
ON public.exercises
FOR SELECT
USING (is_custom = FALSE OR created_by_user_id = auth.uid());

DROP POLICY IF EXISTS "Users can create custom exercises" ON public.exercises;
CREATE POLICY "Users can create custom exercises"
ON public.exercises
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = created_by_user_id AND is_custom = TRUE);

DROP POLICY IF EXISTS "Users can update own custom exercises" ON public.exercises;
CREATE POLICY "Users can update own custom exercises"
ON public.exercises
FOR UPDATE
TO authenticated
USING (auth.uid() = created_by_user_id)
WITH CHECK (auth.uid() = created_by_user_id);

DROP POLICY IF EXISTS "Users can delete own custom exercises" ON public.exercises;
CREATE POLICY "Users can delete own custom exercises"
ON public.exercises
FOR DELETE
TO authenticated
USING (auth.uid() = created_by_user_id);

-- 7. Auto-update 'updated_at' trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_exercises_updated_at ON public.exercises;
CREATE TRIGGER trigger_exercises_updated_at
BEFORE UPDATE ON public.exercises
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Comments for database documentation
COMMENT ON TABLE public.exercises IS 'Master catalog of fitness exercises including warm-up, main, and cool-down movements.';
COMMENT ON COLUMN public.exercises.stage IS 'Movement phase: warmup, main, or cooldown.';
