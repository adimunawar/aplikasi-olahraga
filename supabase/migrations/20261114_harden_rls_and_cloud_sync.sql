-- =============================================================================
-- Migration: 20261114_harden_rls_and_cloud_sync.sql
-- Purpose:
--   * Close the public-read policy that exposed custom exercises.
--   * Make published program catalog rows read-only and hide drafts.
--   * Ensure every personal table has owner-scoped RLS and grants.
--   * Create the remote settings/measurement tables used by Flutter.
--
-- Apply only after reviewing the target Supabase project's current schema.
-- This is a forward-only corrective migration; do not rewrite old migrations.
-- =============================================================================

-- Tables referenced by the mobile data sources but previously missing from
-- the repository's migration history.
CREATE TABLE IF NOT EXISTS public.user_settings (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL UNIQUE,
    gender TEXT NOT NULL DEFAULT 'Male',
    target_weight_kg NUMERIC NOT NULL DEFAULT 65.0,
    training_intensity TEXT NOT NULL DEFAULT 'Moderate',
    workout_reminder BOOLEAN NOT NULL DEFAULT TRUE,
    reminder_time TEXT NOT NULL DEFAULT '08:00 PM',
    rest_day_reminder BOOLEAN NOT NULL DEFAULT TRUE,
    progress_checkin BOOLEAN NOT NULL DEFAULT TRUE,
    streak_reminder BOOLEAN NOT NULL DEFAULT TRUE,
    language TEXT NOT NULL DEFAULT 'English',
    theme TEXT NOT NULL DEFAULT 'Light',
    haptic_feedback BOOLEAN NOT NULL DEFAULT TRUE,
    sound_effects BOOLEAN NOT NULL DEFAULT TRUE,
    data_sync BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.user_settings
    ADD COLUMN IF NOT EXISTS user_id TEXT,
    ADD COLUMN IF NOT EXISTS gender TEXT NOT NULL DEFAULT 'Male',
    ADD COLUMN IF NOT EXISTS target_weight_kg NUMERIC NOT NULL DEFAULT 65.0,
    ADD COLUMN IF NOT EXISTS training_intensity TEXT NOT NULL DEFAULT 'Moderate',
    ADD COLUMN IF NOT EXISTS workout_reminder BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS reminder_time TEXT NOT NULL DEFAULT '08:00 PM',
    ADD COLUMN IF NOT EXISTS rest_day_reminder BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS progress_checkin BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS streak_reminder BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS language TEXT NOT NULL DEFAULT 'English',
    ADD COLUMN IF NOT EXISTS theme TEXT NOT NULL DEFAULT 'Light',
    ADD COLUMN IF NOT EXISTS haptic_feedback BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS sound_effects BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS data_sync BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Existing local-only/default rows must not become associated with a real user.
-- Cloud rows are written with id = user_id = auth.uid() by the mobile client.
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_settings_user_id
    ON public.user_settings(user_id)
    WHERE user_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.body_measurements (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    measurement_type TEXT NOT NULL,
    value NUMERIC NOT NULL,
    unit TEXT NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_body_measurements_owner_recorded
    ON public.body_measurements(user_id, recorded_at DESC);

-- Reset policies on these tables so stale/unknown permissive policies cannot
-- remain alongside the intended owner-only/public-catalog policies.
DO $$
DECLARE
    policy_row RECORD;
BEGIN
    FOR policy_row IN
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = ANY (ARRAY[
              'users',
              'user_profiles',
              'workout_sessions',
              'workout_sets',
              'progression_decisions',
              'training_programs',
              'program_sessions',
              'program_exercises',
              'user_settings',
              'body_measurements',
              'exercises',
              'programs',
              'program_weeks',
              'program_days',
              'program_day_exercises'
          ])
    LOOP
        EXECUTE format(
            'DROP POLICY IF EXISTS %I ON %I.%I',
            policy_row.policyname,
            policy_row.schemaname,
            policy_row.tablename
        );
    END LOOP;
END
$$;

-- Enable RLS on every personal-data table.
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progression_decisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.training_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;

-- Remove all table privileges from anon. Authenticated privileges are granted
-- explicitly below and still constrained by RLS.
REVOKE ALL ON TABLE public.users FROM anon;
REVOKE ALL ON TABLE public.user_profiles FROM anon;
REVOKE ALL ON TABLE public.workout_sessions FROM anon;
REVOKE ALL ON TABLE public.workout_sets FROM anon;
REVOKE ALL ON TABLE public.progression_decisions FROM anon;
REVOKE ALL ON TABLE public.training_programs FROM anon;
REVOKE ALL ON TABLE public.program_sessions FROM anon;
REVOKE ALL ON TABLE public.program_exercises FROM anon;
REVOKE ALL ON TABLE public.user_settings FROM anon;
REVOKE ALL ON TABLE public.body_measurements FROM anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.users TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.workout_sessions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.workout_sets TO authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.progression_decisions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.training_programs TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.program_sessions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.program_exercises TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.user_settings TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.body_measurements TO authenticated;

-- users: the authenticated subject may only access its own row.
CREATE POLICY users_owner_select ON public.users
    FOR SELECT TO authenticated
    USING (id = auth.uid()::TEXT);
CREATE POLICY users_owner_insert ON public.users
    FOR INSERT TO authenticated
    WITH CHECK (id = auth.uid()::TEXT);
CREATE POLICY users_owner_update ON public.users
    FOR UPDATE TO authenticated
    USING (id = auth.uid()::TEXT)
    WITH CHECK (id = auth.uid()::TEXT);
CREATE POLICY users_owner_delete ON public.users
    FOR DELETE TO authenticated
    USING (id = auth.uid()::TEXT);

-- user_profiles: id is the auth user id in the current application schema.
CREATE POLICY user_profiles_owner_select ON public.user_profiles
    FOR SELECT TO authenticated
    USING (id = auth.uid()::TEXT);
CREATE POLICY user_profiles_owner_insert ON public.user_profiles
    FOR INSERT TO authenticated
    WITH CHECK (id = auth.uid()::TEXT);
CREATE POLICY user_profiles_owner_update ON public.user_profiles
    FOR UPDATE TO authenticated
    USING (id = auth.uid()::TEXT)
    WITH CHECK (id = auth.uid()::TEXT);
CREATE POLICY user_profiles_owner_delete ON public.user_profiles
    FOR DELETE TO authenticated
    USING (id = auth.uid()::TEXT);

-- workout_sessions: ownership is carried by user_id.
CREATE POLICY workout_sessions_owner_all ON public.workout_sessions
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::TEXT)
    WITH CHECK (user_id = auth.uid()::TEXT);

-- workout_sets: ownership is inherited from the parent workout session.
CREATE POLICY workout_sets_owner_all ON public.workout_sets
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.workout_sessions AS ws
            WHERE ws.id = workout_sets.session_id
              AND ws.user_id = auth.uid()::TEXT
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.workout_sessions AS ws
            WHERE ws.id = workout_sets.session_id
              AND ws.user_id = auth.uid()::TEXT
        )
    );

-- progression_decisions: owner-only data.
CREATE POLICY progression_decisions_owner_all ON public.progression_decisions
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::TEXT)
    WITH CHECK (user_id = auth.uid()::TEXT);

-- Personal training programs and child rows.
CREATE POLICY training_programs_owner_all ON public.training_programs
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::TEXT)
    WITH CHECK (user_id = auth.uid()::TEXT);

CREATE POLICY program_sessions_owner_all ON public.program_sessions
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.training_programs AS tp
            WHERE tp.id = program_sessions.program_id
              AND tp.user_id = auth.uid()::TEXT
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.training_programs AS tp
            WHERE tp.id = program_sessions.program_id
              AND tp.user_id = auth.uid()::TEXT
        )
    );

CREATE POLICY program_exercises_owner_all ON public.program_exercises
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.program_sessions AS ps
            JOIN public.training_programs AS tp ON tp.id = ps.program_id
            WHERE ps.id = program_exercises.program_session_id
              AND tp.user_id = auth.uid()::TEXT
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.program_sessions AS ps
            JOIN public.training_programs AS tp ON tp.id = ps.program_id
            WHERE ps.id = program_exercises.program_session_id
              AND tp.user_id = auth.uid()::TEXT
        )
    );

-- User settings: id and user_id must both identify the authenticated user.
CREATE POLICY user_settings_owner_all ON public.user_settings
    FOR ALL TO authenticated
    USING (
        id = auth.uid()::TEXT
        AND user_id = auth.uid()::TEXT
    )
    WITH CHECK (
        id = auth.uid()::TEXT
        AND user_id = auth.uid()::TEXT
    );

-- Body measurements: every row is scoped to its authenticated owner.
CREATE POLICY body_measurements_owner_all ON public.body_measurements
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::TEXT)
    WITH CHECK (user_id = auth.uid()::TEXT);

-- Exercise catalog: public may read standard exercises only; authenticated
-- users may additionally read their own custom exercises.
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.exercises FROM anon, authenticated;
GRANT SELECT ON TABLE public.exercises TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON TABLE public.exercises TO authenticated;

CREATE POLICY exercises_catalog_or_owner_select ON public.exercises
    FOR SELECT TO anon, authenticated
    USING (
        is_custom = FALSE
        OR (
            auth.uid() IS NOT NULL
            AND created_by_user_id = auth.uid()
        )
    );

CREATE POLICY exercises_owner_insert ON public.exercises
    FOR INSERT TO authenticated
    WITH CHECK (
        is_custom = TRUE
        AND created_by_user_id = auth.uid()
    );

CREATE POLICY exercises_owner_update ON public.exercises
    FOR UPDATE TO authenticated
    USING (
        is_custom = TRUE
        AND created_by_user_id = auth.uid()
    )
    WITH CHECK (
        is_custom = TRUE
        AND created_by_user_id = auth.uid()
    );

CREATE POLICY exercises_owner_delete ON public.exercises
    FOR DELETE TO authenticated
    USING (
        is_custom = TRUE
        AND created_by_user_id = auth.uid()
    );

-- Published CMS programs are public read-only. Draft/unpublished programs and
-- their nested content remain hidden from mobile clients.
ALTER TABLE public.programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_weeks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_day_exercises ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.programs FROM anon, authenticated;
REVOKE ALL ON TABLE public.program_weeks FROM anon, authenticated;
REVOKE ALL ON TABLE public.program_days FROM anon, authenticated;
REVOKE ALL ON TABLE public.program_day_exercises FROM anon, authenticated;

GRANT SELECT ON TABLE public.programs TO anon, authenticated;
GRANT SELECT ON TABLE public.program_weeks TO anon, authenticated;
GRANT SELECT ON TABLE public.program_days TO anon, authenticated;
GRANT SELECT ON TABLE public.program_day_exercises TO anon, authenticated;

CREATE POLICY programs_published_select ON public.programs
    FOR SELECT TO anon, authenticated
    USING (is_published = TRUE);

CREATE POLICY program_weeks_published_select ON public.program_weeks
    FOR SELECT TO anon, authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.programs AS p
            WHERE p.id = program_weeks.program_id
              AND p.is_published = TRUE
        )
    );

CREATE POLICY program_days_published_select ON public.program_days
    FOR SELECT TO anon, authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.program_weeks AS pw
            JOIN public.programs AS p ON p.id = pw.program_id
            WHERE pw.id = program_days.program_week_id
              AND p.is_published = TRUE
        )
    );

CREATE POLICY program_day_exercises_published_select ON public.program_day_exercises
    FOR SELECT TO anon, authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.program_days AS pd
            JOIN public.program_weeks AS pw ON pw.id = pd.program_week_id
            JOIN public.programs AS p ON p.id = pw.program_id
            WHERE pd.id = program_day_exercises.program_day_id
              AND p.is_published = TRUE
        )
    );

COMMENT ON TABLE public.user_settings IS
    'Private user settings. Access is restricted to auth.uid() = id = user_id.';
COMMENT ON TABLE public.body_measurements IS
    'Private body measurement history. Access is restricted to auth.uid() = user_id.';
