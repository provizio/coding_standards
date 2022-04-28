"""
File: setup.py

Description:
    Sample setup script.

Copyright Provizio Ltd., 2022
Author: Dane Mitrev
"""
import os
from setuptools import setup


def read(file_name):
    return open(os.path.join(os.path.dirname(__file__), file_name)).read()


setup(
    name="src",
    version="0.0.1",
    author="Provizio Developer",
    author_email="namesurname@provizio.ai",
    description="A description of the package and its functionalities",
    license="BSD",
    keywords="example documentation tutorial",
    # url="http://packages.python.org/an_example_pypi_project",
    packages=['src', 'test'],
    long_description=read('README.md'),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
        "License :: OSI Approved :: BSD License",
    ],
)
