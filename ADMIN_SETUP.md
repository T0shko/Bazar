# Admin Setup Guide

This guide explains how to make a user an admin in the Bazar Sales application.

## Method 1: Using Supabase SQL Editor (Recommended)

1. Open your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Run the following SQL command, replacing `'admin@example.com'` with the actual email address of the user you want to make admin:

```sql
UPDATE user_profiles 
SET role = 'admin' 
WHERE email = 'admin@example.com';
```

4. Verify the change:

```sql
SELECT id, email, username, role 
FROM user_profiles 
WHERE email = 'admin@example.com';
```

You should see `role` set to `'admin'`.

## Method 2: Using Supabase Table Editor

1. Open your Supabase project dashboard
2. Navigate to **Table Editor**
3. Select the `user_profiles` table
4. Find the user you want to make admin (search by email)
5. Click on the row to edit it
6. Change the `role` field from `'user'` to `'admin'`
7. Save the changes

## Method 3: Using Supabase REST API

You can also use the Supabase REST API or any database client to update the role:

```sql
UPDATE user_profiles 
SET role = 'admin', 
    updated_at = NOW()
WHERE email = 'admin@example.com';
```

## Verify Admin Access

After making a user an admin:

1. Have the user sign out and sign back in (or refresh the app)
2. The **Analytics** tab should now appear in the bottom navigation
3. They should be able to:
   - View all action logs
   - See analytics charts
   - Rollback actions
   - View calendar-based performance data

## Notes

- Only users with `role = 'admin'` can access the Analytics screen
- Regular users (`role = 'user'`) will not see the Analytics tab
- The role is stored in the `user_profiles` table
- Changes take effect after the user signs out and signs back in (or app refresh)

## Troubleshooting

If the Analytics tab doesn't appear after making a user admin:

1. Make sure the user signs out and signs back in
2. Check that the `user_profiles` table has the correct `role` value:
   ```sql
   SELECT id, email, role FROM user_profiles WHERE email = 'your-email@example.com';
   ```
3. Verify the user profile was created (run the migration script if needed)
4. Check the app logs for any errors

