"""
File: code_standards_enforce.py

Description:
    This automation script should not be executed by a user.

Copyright Provizio Ltd., 2022
Author: Dane Mitrev
"""
import os
import glob
import subprocess
import urllib.request
import argparse

parser = argparse.ArgumentParser(description='Code standards check. Accepts only single arg: '
                                             'sources directory, default one is assumed `src`.')
parser.add_argument("sources_dir", help="Sources directory name.")
args = parser.parse_args()

SOURCES_DIR = args.sources_dir or "src"
print("Sources dir set to: ", SOURCES_DIR)

# 1 Check requirements file exists
if not os.path.isfile("requirements.txt"):
    raise RuntimeError("A `requirements.txt` file was not found. According to coding standards, "
                       "a requirements file must be present in the root folder of the project")

# 2 Check setup.py exists
if not os.path.isfile("setup.py"):
    raise RuntimeError("A `setup.py` file was not found. According to coding standards, "
                       "a setup file must be present in the root folder of the project.")

# 3 Check README file exists
if not glob.glob("*README*"):
    raise RuntimeError("A `README` file was not found. According to coding standards, a README"
                       " file must be present in the root folder of the project.")

# TODO: Change path
TOX_INI_CFG = "https://raw.githubusercontent.com/provizio/coding_standards/master/python/tox.ini"
urllib.request.urlretrieve(TOX_INI_CFG, "tox.ini")

subprocess.run(["tox", SOURCES_DIR])
