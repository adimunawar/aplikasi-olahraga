-- ==============================================================================
-- Migration: 20261107_create_users_and_update_profiles.sql
-- Description: Tabel users & user_profiles adaptif dengan RLS & audit timestamps
-- Database: Supabase (PostgreSQL)
-- Safe & Idempotent: Menambahkan kolom baru jika tabel sudah pernah dibuat sebelumnya
-- ==============================================================================

-- 1. Tabel users publik (cermin dari auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY,
    email TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own record" ON public.users;
CREATE POLICY "Users can view their own record"
ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update their own record" ON public.users;
CREATE POLICY "Users can update their own record"
ON public.users FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Users can insert their own record" ON public.users;
CREATE POLICY "Users can insert their own record"
ON public.users FOR INSERT WITH CHECK (true);

-- 2. Tabel user_profiles (Menambahkan kolom baru secara aman)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id TEXT PRIMARY KEY
);

-- Pastikan kedua kolom id dan user_id terdefinisi agar kompatibel ke semua versi schema
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS id TEXT;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS user_id TEXT;

-- Pastikan seluruh kolom baru Fase 1 (Onboarding Adaptif) ditambahkan
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS display_name TEXT NOT NULL DEFAULT 'User';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS age INTEGER NOT NULL DEFAULT 25;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS height_cm NUMERIC NOT NULL DEFAULT 170.0;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS current_weight_kg NUMERIC NOT NULL DEFAULT 65.0;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS goal TEXT NOT NULL DEFAULT 'muscle_gain';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS experience_level TEXT NOT NULL DEFAULT 'beginner';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS preferred_duration_min INTEGER NOT NULL DEFAULT 30;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS weekly_frequency INTEGER NOT NULL DEFAULT 3;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS available_days JSONB NOT NULL DEFAULT '["monday", "wednesday", "friday"]'::jsonb;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS training_limitations JSONB NOT NULL DEFAULT '[]'::jsonb;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS equipments JSONB NOT NULL DEFAULT '["bodyweight", "mat"]'::jsonb;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS timezone TEXT;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS unit_preference TEXT NOT NULL DEFAULT 'metric';
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now());

-- Indexing user_profiles
CREATE INDEX IF NOT EXISTS idx_user_profiles_goal ON public.user_profiles(goal);
CREATE INDEX IF NOT EXISTS idx_user_profiles_experience ON public.user_profiles(experience_level);
CREATE INDEX IF NOT EXISTS idx_user_profiles_days ON public.user_profiles USING GIN (available_days);
CREATE INDEX IF NOT EXISTS idx_user_profiles_equipments ON public.user_profiles USING GIN (equipments);

-- Enable RLS untuk user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow users to view own profile" ON public.user_profiles;
CREATE POLICY "Allow users to view own profile"
ON public.user_profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow users to insert own profile" ON public.user_profiles;
CREATE POLICY "Allow users to insert own profile"
ON public.user_profiles FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow users to update own profile" ON public.user_profiles;
CREATE POLICY "Allow users to update own profile"
ON public.user_profiles FOR UPDATE USING (true);
