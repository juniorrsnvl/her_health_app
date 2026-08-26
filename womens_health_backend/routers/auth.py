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
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


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

        cursor.execute(
            """
            INSERT INTO users
            (role_id, email, password_hash, is_verified, is_active)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (1, user.email, password_hash, False, True)
        )

        connection.commit()

        return {
            "message": "Account created successfully."
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