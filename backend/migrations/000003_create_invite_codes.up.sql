CREATE TABLE invite_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) UNIQUE NOT NULL,
  owner_user_id UUID NOT NULL REFERENCES users(id),
  owner_type VARCHAR(10) NOT NULL CHECK (owner_type IN ('admin', 'farmer')),
  max_uses INTEGER NOT NULL DEFAULT 2,
  used_count INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  expires_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
