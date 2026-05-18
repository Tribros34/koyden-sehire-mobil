-- Revert: drop any customer rows then restore original constraint.
DELETE FROM users WHERE role = 'customer';
ALTER TABLE users DROP CONSTRAINT users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check
  CHECK (role IN ('admin', 'farmer'));
