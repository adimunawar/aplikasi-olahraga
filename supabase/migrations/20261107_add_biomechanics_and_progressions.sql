-- ==============================================================================
-- Migration: 20261107_add_biomechanics_and_progressions.sql
-- Description: Menambahkan metadata biomekanika, equipments, dan tabel exercise_progressions
-- Database: Supabase (PostgreSQL)
-- ==============================================================================

-- 1. Tambah kolom movement_pattern dan equipments ke tabel exercises
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS movement_pattern TEXT NOT NULL DEFAULT 'other';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS equipments JSONB NOT NULL DEFAULT '["none"]'::jsonb;

CREATE INDEX IF NOT EXISTS idx_exercises_movement_pattern ON public.exercises(movement_pattern);
CREATE INDEX IF NOT EXISTS idx_exercises_equipments ON public.exercises USING GIN (equipments);

-- 2. Update metadata biomekanika & equipments untuk 17 gerakan yang ada
UPDATE public.exercises SET movement_pattern = 'horizontal_push', equipments = '["none"]'::jsonb WHERE id IN ('push_up', 'diamond_push_up');
UPDATE public.exercises SET movement_pattern = 'horizontal_push', equipments = '["stable_surface"]'::jsonb WHERE id = 'incline_push_up';
UPDATE public.exercises SET movement_pattern = 'horizontal_push', equipments = '["mat"]'::jsonb WHERE id = 'knee_push_up';
UPDATE public.exercises SET movement_pattern = 'horizontal_push', equipments = '["elevated_surface"]'::jsonb WHERE id = 'decline_push_up';
UPDATE public.exercises SET movement_pattern = 'vertical_push', equipments = '["none"]'::jsonb WHERE id = 'pike_push_up';
UPDATE public.exercises SET movement_pattern = 'squat', equipments = '["none"]'::jsonb WHERE id IN ('squat', 'squat_jump');
UPDATE public.exercises SET movement_pattern = 'lunge', equipments = '["none"]'::jsonb WHERE id IN ('lunges', 'split_squat');
UPDATE public.exercises SET movement_pattern = 'hip_hinge', equipments = '["mat"]'::jsonb WHERE id = 'glute_bridge';
UPDATE public.exercises SET movement_pattern = 'ankle_extension', equipments = '["none"]'::jsonb WHERE id = 'calf_raise';
UPDATE public.exercises SET movement_pattern = 'core', equipments = '["mat"]'::jsonb WHERE id IN ('plank', 'sit_up', 'leg_raise', 'mountain_climber');
UPDATE public.exercises SET movement_pattern = 'full_body_conditioning', equipments = '["none"]'::jsonb WHERE id = 'burpee';

-- 3. Tambah gerakan ke-18: doorframe_row (Horizontal Pull untuk pemula)
INSERT INTO public.exercises (
    id, name_id, name_en, category, stage, difficulty, tracking_type,
    movement_pattern, equipments, primary_muscles, stabilizer_muscles,
    steps_id, steps_en, common_mistakes_id, common_mistakes_en,
    breathing_tips_id, breathing_tips_en,
    start_pose_asset, end_pose_asset, animation_asset, is_custom
) VALUES (
    'doorframe_row', 'Doorframe Row', 'Doorframe Row', 'pull', 'main', 'beginner', 'reps',
    'horizontal_pull', '["doorframe"]'::jsonb,
    '[{"id":"Punggung atas","en":"Upper Back / Rhomboids"},{"id":"Sayap punggung","en":"Lats (Latissimus Dorsi)"},{"id":"Biceps","en":"Biceps"}]'::jsonb,
    '[{"id":"Perut","en":"Core"},{"id":"Bahu belakang","en":"Rear Deltoids"},{"id":"Lengan bawah","en":"Forearms"}]'::jsonb,
    '["Berdiri tegak menghadap kusen atau tiang pintu yang kokoh.","Pegang kusen pintu dengan kedua tangan setinggi dada.","Dekatkan kedua ujung kaki ke dasar kusen pintu, lalu rebahkan badan ke belakang hingga kedua lengan lurus.","Kunci otot perut dan jaga tubuh lurus kencang dari kepala hingga tumit.","Tarik dada mendekat ke kusen pintu dengan merapatkan kedua tulang belikat.","Tahan kontraksi selama 1 detik di posisi puncak, lalu turunkan badan kembali secara perlahan dan terkontrol."]'::jsonb,
    '["Stand facing a sturdy doorframe or vertical post.","Grip the edge of the doorframe firmly with both hands at chest height.","Walk your feet forward near the base of the frame, then lean back until arms are fully extended.","Engage your core, keeping your body in a straight plank line from head to heels.","Pull your chest toward the doorframe by squeezing your shoulder blades together firmly.","Pause for 1 second at the top, then slowly lower your body under control back to the starting position."]'::jsonb,
    '["Hanya menarik dengan kekuatan tangan tanpa mengaktifkan otot punggung.","Pinggang melorot ke belakang saat menarik badan.","Melakukan gerakan menyentak tanpa kontrol."]'::jsonb,
    '["Pulling exclusively with arms rather than engaging back muscles.","Allowing the lower back or hips to sag backwards.","Jerking the body up quickly without tension."]'::jsonb,
    'Hembuskan napas saat menarik badan mendekat ke pintu, tarik napas saat menurunkan badan kembali.',
    'Exhale as you pull your chest to the frame, inhale as you lower yourself back down.',
    'assets/images/exercises/doorframe_row_start.webp',
    'assets/images/exercises/doorframe_row_end.webp',
    'assets/images/exercises/doorframe_row.webp',
    FALSE
) ON CONFLICT (id) DO UPDATE SET
    movement_pattern = EXCLUDED.movement_pattern,
    equipments = EXCLUDED.equipments,
    category = EXCLUDED.category,
    primary_muscles = EXCLUDED.primary_muscles,
    steps_id = EXCLUDED.steps_id,
    steps_en = EXCLUDED.steps_en;

-- 4. Buat Tabel exercise_progressions (Tangga Evolusi Gerakan)
CREATE TABLE IF NOT EXISTS public.exercise_progressions (
    id TEXT PRIMARY KEY,
    from_exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    to_exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    progression_type TEXT NOT NULL DEFAULT 'difficulty_increase',
    min_success_sessions INTEGER NOT NULL DEFAULT 2,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_progressions_from ON public.exercise_progressions(from_exercise_id);
CREATE INDEX IF NOT EXISTS idx_progressions_to ON public.exercise_progressions(to_exercise_id);

-- Enable RLS
ALTER TABLE public.exercise_progressions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view exercise progressions" ON public.exercise_progressions;
CREATE POLICY "Public can view exercise progressions"
ON public.exercise_progressions FOR SELECT USING (TRUE);

-- 5. Seed Tangga Progresi Pemula
INSERT INTO public.exercise_progressions (id, from_exercise_id, to_exercise_id, progression_type, min_success_sessions) VALUES
    ('prog_incline_to_knee', 'incline_push_up', 'knee_push_up', 'difficulty_increase', 2),
    ('prog_knee_to_pushup', 'knee_push_up', 'push_up', 'difficulty_increase', 2),
    ('prog_pushup_to_diamond', 'push_up', 'diamond_push_up', 'difficulty_increase', 2),
    ('prog_pushup_to_decline', 'push_up', 'decline_push_up', 'difficulty_increase', 2),
    ('prog_squat_to_split', 'squat', 'split_squat', 'difficulty_increase', 2),
    ('prog_split_to_lunges', 'split_squat', 'lunges', 'difficulty_increase', 2),
    ('prog_lunges_to_jump', 'lunges', 'squat_jump', 'difficulty_increase', 2),
    ('prog_plank_to_situp', 'plank', 'sit_up', 'difficulty_increase', 2),
    ('prog_situp_to_climber', 'sit_up', 'mountain_climber', 'difficulty_increase', 2)
ON CONFLICT (id) DO NOTHING;

