-- Supabase schema for five-minute-workout
create table if not exists profiles (
  id uuid primary key,
  created_at timestamptz not null default now()
);

create table if not exists idea_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  title text not null,
  status text not null default 'todo',
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists activity_logs (
  id bigserial primary key,
  user_id uuid not null,
  action text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table idea_items enable row level security;
alter table activity_logs enable row level security;

create policy if not exists "idea_items_owner_select" on idea_items
for select using (auth.uid() = user_id);

create policy if not exists "idea_items_owner_write" on idea_items
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "activity_logs_owner_select" on activity_logs
for select using (auth.uid() = user_id);
