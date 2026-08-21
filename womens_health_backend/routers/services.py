from fastapi import APIRouter, Depends
from config.database import get_database_connection
from utils.dependencies import get_current_user


router = APIRouter(
    prefix="/services",
    tags=["Services"]
)


@router.get("")
def get_services(
    current_user=Depends(get_current_user)
):
    connection = get_database_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute(
            """
            SELECT id, name, description
            FROM services
            WHERE is_active = TRUE
            ORDER BY id
            """
        )

        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()