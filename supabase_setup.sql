-- Supabase Database Setup for Bazar Sales App
-- Run this SQL in your Supabase SQL Editor

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  name TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  description TEXT DEFAULT '',
  stock_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create sales table
CREATE TABLE IF NOT EXISTS sales (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  product_id TEXT REFERENCES products(id) ON DELETE SET NULL,
  coffee_amount TEXT,
  donation_amount TEXT,
  quantity INTEGER NOT NULL DEFAULT 1,
  total DECIMAL(10, 2) NOT NULL,
  date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date DESC);
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON sales(product_id);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust based on your security needs)
-- For development: Allow all operations
-- For production: Implement proper authentication and authorization

-- Products policies
CREATE POLICY "Allow public read access for products"
  ON products FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert access for products"
  ON products FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update access for products"
  ON products FOR UPDATE
  USING (true);

CREATE POLICY "Allow public delete access for products"
  ON products FOR DELETE
  USING (true);

-- Sales policies
CREATE POLICY "Allow public read access for sales"
  ON sales FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert access for sales"
  ON sales FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update access for sales"
  ON sales FOR UPDATE
  USING (true);

CREATE POLICY "Allow public delete access for sales"
  ON sales FOR DELETE
  USING (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable realtime for tables (if using Supabase Realtime)
ALTER PUBLICATION supabase_realtime ADD TABLE products;
ALTER PUBLICATION supabase_realtime ADD TABLE sales;

