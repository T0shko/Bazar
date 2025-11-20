-- Migration Script: Create user_profiles for existing users
-- Run this SQL in your Supabase SQL Editor to backfill user profiles for existing users

-- Insert user profiles for all existing auth.users who don't have profiles yet
INSERT INTO user_profiles (id, email, username, role, created_at)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'username', split_part(au.email, '@', 1)) as username,
  'user' as role,
  au.created_at
FROM auth.users au
LEFT JOIN user_profiles up ON au.id = up.id
WHERE up.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- Verify the migration
SELECT 
  COUNT(*) as total_users,
  COUNT(up.id) as users_with_profiles,
  COUNT(*) - COUNT(up.id) as users_without_profiles
FROM auth.users au
LEFT JOIN user_profiles up ON au.id = up.id;

