-- ==============================================================================
-- Migration: 20261108_add_thumbnail_and_media_to_exercises.sql
-- Description: Menambahkan kolom eksplisit thumbnail_url, duration_seconds, dan status
-- Database: Supabase (PostgreSQL)
-- ==============================================================================

-- 1. Tambah kolom thumbnail_url (URL gambar di Cloudflare R2 / CDN)
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- 2. Tambah kolom duration_seconds dan status untuk konsistensi CMS
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS duration_seconds INTEGER NOT NULL DEFAULT 15;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'Aktif';

-- 3. Sinkronkan nilai thumbnail_url dari start_pose_asset / animation_asset jika ada
UPDATE public.exercises 
SET thumbnail_url = COALESCE(start_pose_asset, animation_asset) 
WHERE thumbnail_url IS NULL;

-- 4. Beri index untuk query performa tinggi
CREATE INDEX IF NOT EXISTS idx_exercises_status ON public.exercises(status);

