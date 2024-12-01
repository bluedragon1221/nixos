from typing import Annotated
import subprocess
import tempfile
import shutil
import os

from fastapi import APIRouter, Depends, Request, File, UploadFile
from fastapi.responses import FileResponse

from ..dependencies import UserWithPerms
from ..shared import users, templates

router = APIRouter(
    prefix="/users/{user_hash}/epub-to-mobi"
)

@router.get("/")
def convert_book(
    r: Request,
    current_user: UserWithPerms("can_use_converter")
):
    return templates.TemplateResponse(
        request=r, name="convert_epub_mobi.html",
        context={key: current_user[key] for key in [
            "user_hash", "name", "is_admin"
        ]}
    )

@router.post("/")
def users_submits_book(
    file: Annotated[UploadFile, File(...)],
    current_user: UserWithPerms("can_use_converter")
):
    # Create a temporary file instead of a directory
    with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(file.filename)[1]) as temp_file:
        shutil.copyfileobj(file.file, temp_file)

    try:
        # Close the uploaded file
        file.file.close()

        # Generate the output filename
        output_filename = os.path.splitext(file.filename)[0] + ".mobi"
        output_path = os.path.join(tempfile.gettempdir(), output_filename)

        # Convert the file
        subprocess.run(["ebook-convert", temp_file.name, output_path], check=True)

        # Return the converted file
        return FileResponse(output_path, filename=output_filename)

    except Exception as e:
        # Clean up the temporary file in case of an error
        os.unlink(temp_file.name)
        raise e
