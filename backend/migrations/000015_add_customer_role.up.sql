-- Allow 'customer' as a third role for end-users who browse/buy products.
-- Existing rows are unaffected (admin/farmer remain valid).
ALTER TABLE users DROP CONSTRAINT users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check
  CHECK (role IN ('admin', 'farmer', 'customer'));
