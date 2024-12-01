from typing import Annotated

from fastapi import APIRouter, Depends, Request, Form
from fastapi.responses import RedirectResponse, FileResponse
from starlette.status import HTTP_302_FOUND

from ..dependencies import get_current_user, book_filename_in_list
from ..shared import templates, users, hash_user_passwd, all_books, books_to_consider

router = APIRouter()

@router.get("/")
def main(): return RedirectResponse(url="/login")

@router.get("/login")
def login_page(r: Request, failed=False):
    return templates.TemplateResponse(
        request=r, name="login_page.html", context={
            "failed_login": failed
        }
    )

@router.post("/login")
def login(
    username: Annotated[str, Form()],
    password: Annotated[str, Form()]
):
    h = hash_user_passwd(username, password)
    if h not in users.keys():
        return RedirectResponse(url="/login/?failed=true", status_code=HTTP_302_FOUND)
    else:
        return RedirectResponse(url=f"/users/{h}", status_code=HTTP_302_FOUND)

@router.get("/users/{user_hash}")
def home_page(
    r: Request,
    current_user: Annotated[dict, Depends(get_current_user())]
):
    # reload the books list on reload (if modified externally)
    all_books.reload()
    books_to_consider.reload()
    
    return templates.TemplateResponse(
        request=r, name="main_page.html",
        context={
            "books_for_users": all_books.get_metadata(),
            "books_to_consider": books_to_consider.get_metadata(),
            **current_user # we end up using all of these values, so might as well take them all
        }
    )

@router.get("/users/{user_hash}/dl/{file_name}")
def download_file(
    r: Request,
    user_hash: Annotated[str, Depends(get_current_user())],
    file_name: Annotated[str, Depends(book_filename_in_list(all_books))]
):
    return FileResponse(f"books/{file_name}", filename=file_name)

