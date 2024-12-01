import hashlib

from fastapi.templating import Jinja2Templates

from .book_stuff import BooksList

def hash_user_passwd(username, password) -> str:
    return hashlib.sha256(f"{username}{password}".encode()).hexdigest()

all_books = BooksList("./books")
books_to_consider = BooksList("./uploaded_books")

templates = Jinja2Templates("./templates")

users = {
    "0e32da59f1e5069c55ac0d532f105d7d15099816a0fff522d3ae48f19deadca1": {
        "user_hash": "0e32da59f1e5069c55ac0d532f105d7d15099816a0fff522d3ae48f19deadca1",
        "name": "collin",
        "is_admin": True,
        "can_manage_books": True,
        "can_download_books": True,
        "can_use_converter": True,
        "can_upload_books": True
    },
    "aee569ef15f2b32e7b22a86418938ee61f317ee592489eaac71236b078063178": {
        "user_hash": "aee569ef15f2b32e7b22a86418938ee61f317ee592489eaac71236b078063178",
        "name": "tweeper",
        "is_admin": False,
        "can_manage_books": False,
        "can_download_books": True,
        "can_use_converter": False,
        "can_upload_books": True
    },
    "0452be820c695c45e245aec15ab3916a2d106015e57bb7cf8f04abcf48bb2132": {
        "user_hash": "0452be820c695c45e245aec15ab3916a2d106015e57bb7cf8f04abcf48bb2132",
        "name": "henry",
        "is_admin": False,
        "can_manage_books": False,
        "can_download_books": True,
        "can_use_converter": True,
        "can_upload_books": True
    },
    "guest": {
        "user_hash": "guest",
        "name": "Guest",
        "is_admin": False,
        "can_manage_books": False,
        "can_download_books": False,
        "can_use_converter": False,
        "can_upload_books": False
    }
}
