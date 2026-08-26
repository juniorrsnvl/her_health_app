from fastapi import FastAPI, Depends
from utils.dependencies import get_current_user
from config.database import get_database_connection
from routers.auth import router as auth_router
from routers.patients import router as patients_router
from routers.services import router as services_router
from routers.appointments import router as appointments_router


app = FastAPI(
    title="Women's Health Companion API",
    version="1.0.0"
)


app.include_router(auth_router)
app.include_router(patients_router)
app.include_router(services_router)
app.include_router(appointments_router)

@app.get("/")
def root():
    return {
        "message": "Women's Health Companion API is running"
    }


@app.get("/database-test")
def database_test(current_user=Depends(get_current_user)):
    connection = get_database_connection()

    if connection.is_connected():
        connection.close()

        return {
            "database": "connected",
            "message": "FastAPI successfully connected to MySQL"
        }

    return {
        "database": "not connected"
    }