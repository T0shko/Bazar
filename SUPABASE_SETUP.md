# Supabase Setup Guide

This guide will help you set up your Supabase database for the Bazar Sales app.

## Prerequisites

1. A Supabase account (sign up at https://supabase.com)
2. A new Supabase project created
3. Your Supabase project URL and anon key

## Step 1: Update Configuration

The app is already configured with your Supabase URL in `lib/app_config.dart`. Make sure the anon key is correct:

```dart
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR_ANON_KEY_HERE',
);
```

**Important**: For production, use environment variables instead of hardcoding keys.

## Step 2: Create Database Tables

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `supabase_setup.sql`
4. Click **Run** to execute the SQL

This will create:

- `products` table - Stores product information
- `sales` table - Stores sales records
- Indexes for better query performance
- Row Level Security (RLS) policies
- Realtime subscriptions enabled

## Step 3: Verify Tables

After running the SQL, verify the tables were created:

1. Go to **Table Editor** in your Supabase dashboard
2. You should see `products` and `sales` tables
3. Check that the columns match the schema in the SQL file

## Step 4: Test the App

1. Run the Flutter app: `flutter run`
2. The app will automatically:
   - Connect to Supabase on startup
   - Subscribe to real-time updates
   - Sync data with the database

## Database Schema

### Products Table

- `id` (TEXT) - Primary key (auto-generated UUID as text)
- `name` (TEXT) - Product name
- `price` (DECIMAL) - Product price
- `description` (TEXT) - Product description
- `stock_quantity` (INTEGER) - Stock count
- `created_at` (TIMESTAMPTZ) - Creation timestamp
- `updated_at` (TIMESTAMPTZ) - Last update timestamp

### Sales Table

- `id` (TEXT) - Primary key (auto-generated UUID as text)
- `product_id` (TEXT) - Foreign key to products (nullable)
- `coffee_amount` (TEXT) - Coffee sale amount (nullable)
- `donation_amount` (TEXT) - Donation amount (nullable)
- `quantity` (INTEGER) - Sale quantity
- `total` (DECIMAL) - Total sale amount
- `date` (TIMESTAMPTZ) - Sale date
- `created_at` (TIMESTAMPTZ) - Creation timestamp

## Security Notes

The current setup uses public access policies for development. **For production**, you should:

1. Implement proper authentication (Supabase Auth)
2. Update RLS policies to restrict access based on user roles
3. Use service role key for admin operations (never expose in client)
4. Consider implementing user-specific data isolation

## Troubleshooting

### Connection Issues

- Verify your Supabase URL and anon key are correct
- Check your internet connection
- Ensure Supabase project is active

### Real-time Not Working

- Verify Realtime is enabled in Supabase dashboard
- Check that tables are added to the `supabase_realtime` publication
- Ensure RLS policies allow SELECT operations

### Data Not Syncing

- Check browser console or Flutter logs for errors
- Verify table names match exactly (`products`, `sales`)
- Ensure column names match the schema (snake_case)

## Next Steps

1. Set up authentication if needed
2. Configure backup strategies
3. Set up monitoring and alerts
4. Implement proper error handling in the app
