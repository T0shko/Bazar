# Supabase Storage Setup for Product Images

## Step 1: Create Storage Bucket (REQUIRED)

**You MUST create the bucket in Supabase Dashboard before uploading images.**

1. Go to your Supabase project dashboard: https://supabase.com/dashboard
2. Navigate to **Storage** in the left sidebar
3. Click **New bucket** button
4. Configure the bucket:
   - **Name**: `product-images` (exactly this name, lowercase with hyphen)
   - **Public bucket**: ✅ **CHECK THIS** (so images can be accessed via public URLs)
   - **File size limit**: 5 MB (or your preferred limit)
   - **Allowed MIME types**: `image/jpeg, image/png, image/webp` (optional)
5. Click **Create bucket**

## Step 2: Set Up Storage Policies (Run in SQL Editor)

After creating the bucket, go to **SQL Editor** in Supabase and run this SQL:

```sql
-- Storage policies for product-images bucket
-- These allow authenticated users to upload, update, and delete images
-- and allow public read access

-- Policy 1: Allow public read access to product images
CREATE POLICY "Public read access for product images"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

-- Policy 2: Allow authenticated users to upload product images
CREATE POLICY "Authenticated users can upload product images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'product-images' AND
  auth.role() = 'authenticated'
);

-- Policy 3: Allow authenticated users to update product images
CREATE POLICY "Authenticated users can update product images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'product-images' AND
  auth.role() = 'authenticated'
);

-- Policy 4: Allow authenticated users to delete product images
CREATE POLICY "Authenticated users can delete product images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'product-images' AND
  auth.role() = 'authenticated'
);
```

## Alternative: Public Upload (Development/Testing Only)

If you want to allow public uploads without authentication (for development/testing only):

```sql
-- WARNING: Only use this for development, not production!
-- This allows anyone to upload/delete images

CREATE POLICY "Allow all operations for product-images"
ON storage.objects
FOR ALL
USING (bucket_id = 'product-images')
WITH CHECK (bucket_id = 'product-images');
```

## Step 3: Verify Setup

1. Try uploading a product image in the app
2. Check the Storage bucket to see if the image was uploaded
3. Verify the image URL is saved in the products table

## Troubleshooting

- **"Bucket not found" error**: Make sure you created the bucket named exactly `product-images` in the Supabase dashboard
- **403 Forbidden**: Check that your storage policies are set up correctly
- **Image not displaying**: Verify the bucket is set to public, or check the image URL format
- **Upload fails**: Check file size limits and MIME type restrictions in bucket settings

## Important Notes

- The bucket name in code is: `product-images` (must match exactly)
- The bucket must be **public** for images to be accessible via URLs
- Storage policies control who can upload/delete images
- For production, use authenticated-only policies (not the public upload policy)
