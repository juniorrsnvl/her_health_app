-- add_privacy_consent.sql
-- Records each patient's acceptance of the privacy notice (POPIA consent).
-- Safe to re-run. Run on BOTH databases before deploying the new backend.

ALTER TABLE users ADD COLUMN IF NOT EXISTS privacy_accepted_at TIMESTAMP;
ALTER TABLE users ADD COLUMN IF NOT EXISTS privacy_version VARCHAR(40);

-- Accounts created before this change have no consent recorded (NULL).
