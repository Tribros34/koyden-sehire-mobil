CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farmer_id UUID NOT NULL REFERENCES users(id),
  category_id UUID NOT NULL REFERENCES categories(id),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  unit VARCHAR(20) NOT NULL CHECK (unit IN (
    'kg', 'gram', 'adet', 'litre', 'kasa', 'koli', 'demet', 'paket'
  )),
  city VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  village VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (
    status IN ('draft', 'pending', 'active', 'passive', 'rejected', 'hidden')
  ),
  previous_status VARCHAR(20),
  stock_status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (
    stock_status IN ('available', 'unavailable')
  ),
  admin_note TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
