from datetime import date
from decimal import Decimal
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from config.database import get_database_connection
from utils.dependencies import get_current_user
from utils.audit import log_access


router = APIRouter(prefix="/billing", tags=["Billing"])

BillingStatus = Literal["unpaid", "partially_paid", "paid"]


class BillCreateRequest(BaseModel):
    patient_id: int
    description: str
    amount: Decimal
    due_date: date | None = None
    status: BillingStatus = "unpaid"


class BillUpdateRequest(BaseModel):
    description: str
    amount: Decimal
    due_date: date | None = None
    status: BillingStatus


def _require_staff(current_user):
    if current_user["role_id"] not in [2, 3, 4]:
        raise HTTPException(
            status_code=403,
            detail="You do not have permission to manage billing.",
        )


@router.get("/me")
def get_my_bills(current_user=Depends(get_current_user)):
    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM patients WHERE user_id = %s",
            (current_user["user_id"],),
        )
        patient = cursor.fetchone()
        if not patient:
            raise HTTPException(status_code=404, detail="Patient profile not found.")

        cursor.execute(
            """
            SELECT id, patient_id, description, amount, due_date, status,
                   created_at, updated_at
            FROM bills
            WHERE patient_id = %s
            ORDER BY created_at DESC
            """,
            (patient["id"],),
        )
        return cursor.fetchall()
    finally:
        cursor.close()
        connection.close()


@router.get("/all")
def get_all_bills(current_user=Depends(get_current_user)):
    _require_staff(current_user)

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT
                b.id,
                b.patient_id,
                b.description,
                b.amount,
                b.due_date,
                b.status,
                b.created_at,
                b.updated_at,
                p.first_name,
                p.last_name
            FROM bills b
            JOIN patients p ON p.id = b.patient_id
            ORDER BY b.created_at DESC
            """
        )
        rows = cursor.fetchall()
        log_access(cursor, current_user["user_id"], "list_bills")
        connection.commit()
        return rows
    finally:
        cursor.close()
        connection.close()


@router.post("")
def create_bill(
    request: BillCreateRequest,
    current_user=Depends(get_current_user),
):
    _require_staff(current_user)

    if request.amount < 0:
        raise HTTPException(status_code=400, detail="Amount cannot be negative.")
    if not request.description.strip():
        raise HTTPException(status_code=400, detail="Description is required.")

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("SELECT id FROM patients WHERE id = %s", (request.patient_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Patient not found.")

        cursor.execute(
            """
            INSERT INTO bills
                (patient_id, description, amount, due_date, status, created_by_user_id)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING id
            """,
            (
                request.patient_id,
                request.description.strip(),
                request.amount,
                request.due_date,
                request.status,
                current_user["user_id"],
            ),
        )
        bill_id = cursor.fetchone()["id"]
        log_access(
            cursor,
            current_user["user_id"],
            "create_bill",
            request.patient_id,
        )
        connection.commit()

        return {"message": "Bill created successfully.", "id": bill_id}
    finally:
        cursor.close()
        connection.close()


@router.put("/{bill_id}")
def update_bill(
    bill_id: int,
    request: BillUpdateRequest,
    current_user=Depends(get_current_user),
):
    _require_staff(current_user)

    if request.amount < 0:
        raise HTTPException(status_code=400, detail="Amount cannot be negative.")
    if not request.description.strip():
        raise HTTPException(status_code=400, detail="Description is required.")

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT patient_id FROM bills WHERE id = %s",
            (bill_id,),
        )
        existing = cursor.fetchone()
        if not existing:
            raise HTTPException(status_code=404, detail="Bill not found.")

        cursor.execute(
            """
            UPDATE bills
            SET description = %s,
                amount = %s,
                due_date = %s,
                status = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            """,
            (
                request.description.strip(),
                request.amount,
                request.due_date,
                request.status,
                bill_id,
            ),
        )
        log_access(
            cursor,
            current_user["user_id"],
            "update_bill",
            existing["patient_id"],
        )
        connection.commit()

        return {"message": "Bill updated successfully."}
    finally:
        cursor.close()
        connection.close()
