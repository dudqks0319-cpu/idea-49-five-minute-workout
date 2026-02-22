-- Supabase schema for five-minute-workout
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  default_energy_level integer not null default 3,
  daily_focus_minutes integer not null default 180,
  notifications_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists five_minute_workout_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  required_energy integer not null default 3,
  estimated_minutes integer not null default 30,
  status text not null default 'pending',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists activity_logs (
  id bigserial primary key,
  user_id uuid not null,
  action text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table profiles enable row level security;
alter table five_minute_workout_items enable row level security;
alter table activity_logs enable row level security;

create policy if not exists "profiles_self_select" on profiles
for select using (auth.uid() = id);

create policy if not exists "profiles_self_write" on profiles
for update using (auth.uid() = id);

create policy if not exists "five_minute_workout_items_owner_select" on five_minute_workout_items
for select using (auth.uid() = user_id);

create policy if not exists "five_minute_workout_items_owner_insert" on five_minute_workout_items
for insert with check (auth.uid() = user_id);

create policy if not exists "five_minute_workout_items_owner_update" on five_minute_workout_items
for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "five_minute_workout_items_owner_delete" on five_minute_workout_items
for delete using (auth.uid() = user_id);

create policy if not exists "activity_logs_owner_select" on activity_logs
for select using (auth.uid() = user_id);
