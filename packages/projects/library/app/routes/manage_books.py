from typing import Annotated
import shutil
import os

from fastapi import APIRouter, Depends, Request, File, UploadFile
from fastapi.responses import HTMLResponse, RedirectResponse
from starlette.status import HTTP_302_FOUND

from ..dependencies import UserWithPerms, book_filename_in_list, manage_book_action
from ..shared import all_books, books_to_consider, templates
from ..book_stuff import BookAction

router = APIRouter(
    prefix="/users/{user_hash}"
)

@router.get("/submit-a-book")
def submit_book(
    r: Request,
    current_user: UserWithPerms("can_upload_books")
):
    return templates.TemplateResponse(
        request=r, name="submit_book.html",
        context={key: current_user[key] for key in [
            "user_hash", "name", "is_admin"
        ]}
    )

@router.post("/submit-a-book")
def users_submits_book(
    current_user: UserWithPerms("can_upload_books"),
    file: UploadFile = File(...)
):
    try:
        file_path = f"uploaded_books/{current_user.get("user_hash")[:8]}-{file.filename}"
        with open(file_path, "bx") as f:
            shutil.copyfileobj(file.file, f)
    except FileExistsError:
        return "You have already submitted a file with that name"
    finally:
        file.file.close()
        books_to_consider.reload()

    return HTMLResponse(content=f"You're book was submitted successfully! <a href='/users/{current_user.get("user_hash")}'>Return to home page</a>")


@router.post("/manage-submitted-book")
def manage_book(
    current_user: UserWithPerms("can_manage_books"),

    managed_action: Annotated[BookAction, Depends(manage_book_action)],
    book_filename: Annotated[str, Depends(book_filename_in_list(books_to_consider))],
):
    user_hash = current_user.get("user_hash")
    match managed_action:
        case BookAction.Accept:
            os.rename(f"uploaded_books/{book_filename}", f"books/{book_filename}")
            books_to_consider.reload()
            all_books.reload()
        case BookAction.Decline:
            os.remove(f"uploaded_books/{book_filename}")
            books_to_consider.reload()

    return RedirectResponse(url=f"/users/{user_hash}", status_code=HTTP_302_FOUND)
