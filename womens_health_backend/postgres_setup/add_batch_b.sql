-- add_batch_b.sql
-- Batch B: lockouts in the database + staff access log. Safe to re-run.
-- Run on BOTH databases (laptop and Neon) before deploying the new backend.

-- Failed login / code / delete attempts, so lockouts survive restarts.
CREATE TABLE IF NOT EXISTS failed_attempts (
    key            VARCHAR(255) PRIMARY KEY,      -- e.g. 'login:someone@example.com'
    count          INT NOT NULL,
    first_failure  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Which staff member looked at which patient's data, and when.
-- staff_user_id has no ON DELETE rule on purpose: to keep the audit trail,
-- deactivate a departing staff account (is_active = false) instead of deleting it.
CREATE TABLE IF NOT EXISTS access_log (
    id             SERIAL PRIMARY KEY,
    staff_user_id  INT NOT NULL REFERENCES users(id),
    patient_id     INT REFERENCES patients(id) ON DELETE SET NULL,
    action         VARCHAR(50) NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_access_log_patient ON access_log(patient_id);
CREATE INDEX IF NOT EXISTS idx_access_log_staff ON access_log(staff_user_id);
