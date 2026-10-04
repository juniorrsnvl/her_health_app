"""Staff access log: records which staff member viewed which patient's data."""


def log_access(cursor, staff_user_id: int, action: str, patient_id: int | None = None):
    """Adds one row to access_log. The caller commits."""
    cursor.execute(
        "INSERT INTO access_log (staff_user_id, patient_id, action) VALUES (%s, %s, %s)",
        (staff_user_id, patient_id, action),
    )
