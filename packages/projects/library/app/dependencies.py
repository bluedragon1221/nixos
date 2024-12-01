from typing import Annotated

from fastapi import HTTPException, Depends
from starlette.status import HTTP_404_NOT_FOUND, HTTP_302_FOUND, HTTP_401_UNAUTHORIZED, HTTP_500_INTERNAL_SERVER_ERROR

from .book_stuff import BooksList, BookAction
from .shared import users

def get_current_user(perms=None):
    # default mutable args are bad
    perms = [] if perms is None else perms

    def inner(user_hash):
        current_user = users[user_hash]
        if user_hash not in users:
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED,
                detail="Invalid user hash",
            )
        if (type(perms) == list and not all(current_user.get(perm) for perm in perms)) or \
           (type(perms) == str and current_user.get(perm)):
            raise HTTPException(
                status_code=HTTP_401_UNAUTHORIZED,
                detail=f"You don't have permission to be here. User needs '{perms}'",
            )
        return current_user
    return inner

# type alias with lambda in it?
UserWithPerms = lambda *perms: Annotated[dict, Depends(get_current_user(perms=perms))]

def book_filename_in_list(list: BooksList):
    def inner(file_name):
        if not file_name in list.get_filenames():
            raise HTTPException(
                status_code=HTTP_404_NOT_FOUND,
                detail="That file doesn't exist on the server"
            )
        return file_name
    return inner

def manage_book_action(action: str) -> BookAction:
    if action == "accept":
        return BookAction.Accept
    elif action == "decline":
        return BookAction.Decline
    else:
        raise HTTPException(
            status_code=HTTP_500_INTERNAL_SERVER_ERROR,
            message="Unknown action to book"
        )

