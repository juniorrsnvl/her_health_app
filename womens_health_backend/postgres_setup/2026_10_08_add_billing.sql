-- Billing MVP for Her Health
-- Safe to run once on local PostgreSQL and the staging Neon database.

CREATE TABLE IF NOT EXISTS bills (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    due_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'unpaid'
        CHECK (status IN ('unpaid', 'partially_paid', 'paid')),
    created_by_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bills_patient_id ON bills(patient_id);
CREATE INDEX IF NOT EXISTS idx_bills_status ON bills(status);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'set_bills_updated_at'
    ) THEN
        CREATE TRIGGER set_bills_updated_at
        BEFORE UPDATE ON bills
        FOR EACH ROW
        EXECUTE FUNCTION set_updated_at();
    END IF;
END
$$;
