import random
from datetime import datetime, timedelta
from typing import Literal

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from config.database import get_database_connection
from utils.security import hash_password, verify_password, create_access_token


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


class RegisterRequest(BaseModel):
    email: EmailStr
    phone: str
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class VerifyRequest(BaseModel):
    email: EmailStr
    method: Literal["email", "phone"]
    code: str


class ResendCodesRequest(BaseModel):
    email: EmailStr


def _generate_code() -> str:
    """6-digit numeric code, as a zero-padded string (e.g. '004821')."""
    return f"{random.randint(0, 999999):06d}"


@router.post("/register")
def register_user(user: RegisterRequest):

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM users WHERE email = %s",
            (user.email,)
        )

        existing_user = cursor.fetchone()

        if existing_user:
            raise HTTPException(
                status_code=400,
                detail="An account with this email already exists."
            )

        password_hash = hash_password(user.password)

        email_code = _generate_code()
        phone_code = _generate_code()
        expires_at = datetime.utcnow() + timedelta(minutes=10)

        cursor.execute(
            """
            INSERT INTO users
            (role_id, email, phone, password_hash, is_verified, is_active,
             email_code, email_code_expires_at,
             phone_code, phone_code_expires_at, is_phone_verified)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                1,
                user.email,
                user.phone,
                password_hash,
                False,
                True,
                email_code,
                expires_at,
                phone_code,
                expires_at,
                False,
            )
        )

        connection.commit()

        return {
            "message": "Account created successfully. Verification codes generated.",
            # SIMULATED SENDING: these codes would normally go out via an
            # email provider and an SMS provider. No such provider is
            # connected yet, so they're returned here directly for the
            # frontend to display on-screen during development. The user
            # only needs to verify ONE of the two -- their choice.
            "email_code": email_code,
            "phone_code": phone_code,
        }

    finally:
        cursor.close()
        connection.close()


@router.post("/verify")
def verify_user(request: VerifyRequest):
    """
    Verifies the account using EITHER email or phone -- whichever the
    user chooses. Only one successful verification is required; the
    other channel's code is simply left unused.
    """

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, email_code, email_code_expires_at,
                   phone_code, phone_code_expires_at,
                   is_verified, is_phone_verified
            FROM users
            WHERE email = %s
            """,
            (request.email,)
        )

        existing_user = cursor.fetchone()

        if not existing_user:
            raise HTTPException(
                status_code=404,
                detail="No account found for this email."
            )

        now = datetime.utcnow()

        if request.method == "email":
            stored_code = existing_user["email_code"]
            expires_at = existing_user["email_code_expires_at"]
        else:
            stored_code = existing_user["phone_code"]
            expires_at = existing_user["phone_code_expires_at"]

        if expires_at is None or now > expires_at:
            raise HTTPException(
                status_code=400,
                detail="This verification code has expired. Please request a new one."
            )

        if request.code != stored_code:
            raise HTTPException(
                status_code=400,
                detail="Incorrect verification code."
            )

        if request.method == "email":
            cursor.execute(
                """
                UPDATE users
                SET is_verified = TRUE,
                    email_code = NULL,
                    email_code_expires_at = NULL
                WHERE id = %s
                """,
                (existing_user["id"],)
            )
        else:
            cursor.execute(
                """
                UPDATE users
                SET is_phone_verified = TRUE,
                    phone_code = NULL,
                    phone_code_expires_at = NULL
                WHERE id = %s
                """,
                (existing_user["id"],)
            )

        connection.commit()

        return {
            "message": f"Account verified successfully via {request.method}."
        }

    finally:
        cursor.close()
        connection.close()


@router.post("/resend-codes")
def resend_codes(request: ResendCodesRequest):

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT id FROM users WHERE email = %s",
            (request.email,)
        )

        existing_user = cursor.fetchone()

        if not existing_user:
            raise HTTPException(
                status_code=404,
                detail="No account found for this email."
            )

        email_code = _generate_code()
        phone_code = _generate_code()
        expires_at = datetime.utcnow() + timedelta(minutes=10)

        cursor.execute(
            """
            UPDATE users
            SET email_code = %s,
                email_code_expires_at = %s,
                phone_code = %s,
                phone_code_expires_at = %s
            WHERE id = %s
            """,
            (email_code, expires_at, phone_code, expires_at, existing_user["id"])
        )

        connection.commit()

        return {
            "message": "New verification codes generated.",
            # SIMULATED SENDING -- see note in register_user above.
            "email_code": email_code,
            "phone_code": phone_code,
        }

    finally:
        cursor.close()
        connection.close()


@router.post("/login")
def login_user(user: LoginRequest):

    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, role_id, email, password_hash, is_active
            FROM users
            WHERE email = %s
            """,
            (user.email,)
        )

        existing_user = cursor.fetchone()

        if not existing_user:
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        if not existing_user["is_active"]:
            raise HTTPException(
                status_code=403,
                detail="This account is inactive."
            )

        password_correct = verify_password(
            user.password,
            existing_user["password_hash"]
        )

        if not password_correct:
            raise HTTPException(
                status_code=401,
                detail="Invalid email or password."
            )

        token = create_access_token(
            existing_user["id"],
            existing_user["role_id"]
        )

        return {
            "message": "Login successful.",
            "access_token": token,
            "token_type": "bearer"
        }

    finally:
        cursor.close()
        connection.close()
