CREATE TABLE farmer_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255),
  password_hash TEXT NOT NULL,
  phone_verified BOOLEAN NOT NULL DEFAULT false,

  business_name VARCHAR(255) NOT NULL,
  producer_type VARCHAR(50) NOT NULL CHECK (producer_type IN (
    'individual_farmer', 'family_producer', 'cooperative',
    'small_producer', 'dairy_producer', 'beekeeper',
    'olive_producer', 'other'
  )),
  city VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  village VARCHAR(100) NOT NULL,
  bio TEXT NOT NULL,

  product_categories JSONB NOT NULL DEFAULT '[]',
  product_examples TEXT NOT NULL,
  production_place_type VARCHAR(50) CHECK (production_place_type IN (
    'own_land', 'family_land', 'rented_land',
    'cooperative_production', 'home_production', 'other'
  )),
  document_urls JSONB DEFAULT '[]',
  application_note TEXT,

  application_video_key TEXT,
  application_video_url TEXT,
  application_video_status VARCHAR(20) NOT NULL DEFAULT 'missing' CHECK (
    application_video_status IN ('missing', 'uploaded', 'requested', 'not_required')
  ),
  video_requested_at TIMESTAMP,
  video_uploaded_at TIMESTAMP,

  invite_code_id UUID REFERENCES invite_codes(id),
  referred_by_user_id UUID REFERENCES users(id),
  application_source VARCHAR(20) NOT NULL CHECK (
    application_source IN ('admin_created', 'admin_invite', 'farmer_invite')
  ),

  kvkk_accepted BOOLEAN NOT NULL DEFAULT false,
  platform_terms_accepted BOOLEAN NOT NULL DEFAULT false,
  declares_own_production BOOLEAN NOT NULL DEFAULT false,
  declares_accurate_location BOOLEAN NOT NULL DEFAULT false,
  declares_not_intermediary BOOLEAN NOT NULL DEFAULT false,

  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (
    status IN ('pending', 'approved', 'rejected', 'needs_video')
  ),
  rejection_reason VARCHAR(50) CHECK (
    rejection_reason IN (
      'intermediary_suspected',
      'inconsistent_info',
      'video_verification_failed',
      'duplicate_application',
      'out_of_scope_product',
      'other'
    )
  ),
  admin_note TEXT,
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMP,

  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX unique_active_application_phone
ON farmer_applications(phone)
WHERE status IN ('pending', 'needs_video');
