INSERT INTO users (
  full_name, phone, email, password_hash,
  role, status, phone_verified, phone_verified_at
) VALUES (
  'Köyden Şehre Admin',
  '05000000000',
  'admin@koydensehre.com',
  '$2a$12$Xneb3ookrcX5Az0WNGaz0.hunDEajMsUAg/0n.nK6QkCqEbVE/s8q',
  'admin',
  'active',
  true,
  NOW()
) ON CONFLICT (phone) DO NOTHING;
