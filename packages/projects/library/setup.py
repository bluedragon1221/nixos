#!/usr/bin/env python

from setuptools import setup, find_packages

setup(name="library-web",
      version="1.0",
      packages=find_packages(),
      scripts=["app/main.py"],
      )
