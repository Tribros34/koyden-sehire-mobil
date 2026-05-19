-- Ensure the system admin user exists before seeding the founder invite code.
INSERT INTO users (phone, role, is_active)
VALUES ('05000000000', 'admin', true)
ON CONFLICT (phone) DO NOTHING;

INSERT INTO invite_codes (
  code,
  owner_user_id,
  owner_type,
  max_uses,
  used_count,
  is_active
) VALUES (
  'KYS-FOUNDER',
  (SELECT id FROM users WHERE phone = '05000000000'),
  'admin',
  50,
  0,
  true
) ON CONFLICT (code) DO NOTHING;
