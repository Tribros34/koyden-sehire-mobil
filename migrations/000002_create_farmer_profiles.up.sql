CREATE TABLE farmer_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  display_name VARCHAR(255) NOT NULL,
  producer_type VARCHAR(50) NOT NULL CHECK (producer_type IN (
    'individual_farmer', 'family_producer', 'cooperative',
    'small_producer', 'dairy_producer', 'beekeeper',
    'olive_producer', 'other'
  )),
  city VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  village VARCHAR(100) NOT NULL,
  bio TEXT NOT NULL,
  profile_image_url TEXT,
  public_phone VARCHAR(20) NOT NULL,
  show_phone BOOLEAN NOT NULL DEFAULT true,
  is_verified BOOLEAN NOT NULL DEFAULT false,
  is_founding_farmer BOOLEAN NOT NULL DEFAULT false,
  invite_quota INTEGER NOT NULL DEFAULT 2,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
