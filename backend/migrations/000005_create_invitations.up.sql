CREATE TABLE invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invite_code_id UUID NOT NULL REFERENCES invite_codes(id),
  inviter_user_id UUID NOT NULL REFERENCES users(id),
  application_id UUID REFERENCES farmer_applications(id),
  status VARCHAR(20) NOT NULL DEFAULT 'started' CHECK (
    status IN ('started', 'submitted', 'approved', 'rejected', 'expired')
  ),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
