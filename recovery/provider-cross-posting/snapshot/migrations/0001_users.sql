CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS app_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL,
  display_name text NOT NULL,
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT app_users_email_lowercase CHECK (email = lower(email))
);
CREATE UNIQUE INDEX IF NOT EXISTS app_users_email_unique ON app_users(email);

-- Generate a hash outside SQL, then insert the first organizer explicitly:
-- INSERT INTO app_users (email, display_name, password_hash)
-- VALUES ('owner@example.com', 'Owner', '$argon2id$...');
