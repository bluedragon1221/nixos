from fastapi import FastAPI

from app.routes import main, manage_books, converter

app = FastAPI()
app.include_router(main.router)
app.include_router(manage_books.router)
app.include_router(converter.router)
