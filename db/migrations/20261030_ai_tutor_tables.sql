-- AI Voice Teacher: tutor_settings + tutor_chats
-- RLS: her kullanıcı yalnızca kendi satırlarını görür/yazar.
-- anon erişimi kapalı; grant'lar açıkça verilir.

create table public.tutor_settings (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  english_level text not null default 'B1'
    check (english_level in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  correction_level text not null default 'medium'
    check (correction_level in ('low', 'medium', 'high'))
);

create table public.tutor_chats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  summary text not null check (length(btrim(summary)) > 0),
  created_at timestamptz not null default now()
);

create index idx_tutor_chats_user_created
  on public.tutor_chats (user_id, created_at desc);

alter table public.tutor_settings enable row level security;
alter table public.tutor_chats enable row level security;

-- Yeni tablolar public şemasında anon/authenticated'a varsayılan olarak
-- tüm yetkilerle açılır; bu yüzden önce hepsi geri alınır, sonra en az
-- yetki yeniden verilir.
revoke all on table public.tutor_settings from anon, authenticated;
revoke all on table public.tutor_chats from anon, authenticated;

grant select, insert, update on table public.tutor_settings to authenticated;
grant select, insert on table public.tutor_chats to authenticated;
grant select, insert, update, delete on table public.tutor_settings to service_role;
grant select, insert, update, delete on table public.tutor_chats to service_role;

create policy "Users can view only their own tutor settings"
  on public.tutor_settings for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert only their own tutor settings"
  on public.tutor_settings for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update only their own tutor settings"
  on public.tutor_settings for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can view only their own tutor chats"
  on public.tutor_chats for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert only their own tutor chats"
  on public.tutor_chats for insert
  to authenticated
  with check ((select auth.uid()) = user_id);
