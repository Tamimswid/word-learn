-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.words (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid(),
  word text NOT NULL CHECK (length(TRIM(BOTH FROM word)) > 0),
  translation text NOT NULL CHECK (length(TRIM(BOTH FROM translation)) > 0),
  example_sentence text NOT NULL,
  sentence_blank text NOT NULL,
  options_json jsonb NOT NULL,
  error_count integer NOT NULL DEFAULT 0 CHECK (error_count >= 0),
  success_count integer NOT NULL DEFAULT 0 CHECK (success_count >= 0),
  mastery_level smallint NOT NULL DEFAULT 0 CHECK (mastery_level = ANY (ARRAY[0, 1, 2])),
  last_reviewed_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT words_pkey PRIMARY KEY (id),
  CONSTRAINT words_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.daily_activities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid(),
  activity_date date NOT NULL,
  reviewed_count integer NOT NULL DEFAULT 0 CHECK (reviewed_count >= 0 AND reviewed_count <= 100),
  is_completed boolean NOT NULL DEFAULT false,
  CONSTRAINT daily_activities_pkey PRIMARY KEY (id),
  CONSTRAINT daily_activities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() UNIQUE,
  daily_notification_limit integer NOT NULL DEFAULT 10 CHECK (daily_notification_limit >= 5 AND daily_notification_limit <= 50),
  current_streak integer NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak integer NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
  last_active_date date,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT user_settings_pkey PRIMARY KEY (id),
  CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.tutor_settings (
  user_id uuid NOT NULL DEFAULT auth.uid(),
  english_level text NOT NULL DEFAULT 'B1' CHECK (english_level = ANY (ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2'])),
  correction_level text NOT NULL DEFAULT 'medium' CHECK (correction_level = ANY (ARRAY['low', 'medium', 'high'])),
  CONSTRAINT tutor_settings_pkey PRIMARY KEY (user_id),
  CONSTRAINT tutor_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);
CREATE TABLE public.tutor_chats (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid(),
  summary text NOT NULL CHECK (length(btrim(summary)) > 0),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT tutor_chats_pkey PRIMARY KEY (id),
  CONSTRAINT tutor_chats_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);
CREATE INDEX idx_tutor_chats_user_created ON public.tutor_chats USING btree (user_id, created_at DESC);