from enum import Enum
from typing import TypedDict, Optional
from os import path
from glob import glob

import epub_meta

BookAction = Enum("BookAction", ["Accept", "Decline"])

class EpubMeta(TypedDict):
    base64_image: str
    title: str
    author: str
    path: str

class BookMetadata:
    def __init__(self, p):
        self.path = p
        self.filename = path.basename(p)
        self.metadata = BookMetadata.gen_data(p)

    @staticmethod
    def gen_data(file_path) -> Optional[EpubMeta]:
        try:
            book_data = epub_meta.get_epub_metadata(file_path, read_cover_image=True, read_toc=False)
            base64_image = book_data.cover_image_content.decode('utf-8') if book_data.cover_image_content else None
            return {
                "base64_image": base64_image,
                "title": book_data.title,
                "author": book_data.authors[0] if len(book_data.authors) > 0 else None,
                "path": path.basename(file_path)
            }
        except epub_meta.exceptions.EPubException as e:
            print(f"EPubException: {e} (file: {file_path})")
            return None

class BooksList:
    def __init__(self, books_path):
        self.books_path = books_path
        self.books = self.__load_books()

    def __load_books(self):
        return [BookMetadata(i) for i in glob(f"{self.books_path}/*.epub")]

    def get_filenames(self):
        return [i.filename for i in self.books]

    def get_metadata(self):
        return [i.metadata for i in self.books]

    def reload(self):
        self.books = self.__load_books()
