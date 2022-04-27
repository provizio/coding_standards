"""
File: code_standards_check.py

Description:
    This scrip checks if a python codebase is compliant with Provizio code standards.
    The script accepts the sources dir as an argument

Copyright Provizio Ltd., 2022
Author: Dane Mitrev
"""
import argparse
import subprocess
import urllib.request


parser = argparse.ArgumentParser(description='Code standards check. Accepts only single arg:'
                                             ' sources directory, default one is assumed `src`.')
parser.add_argument("sources_dir", help="Sources directory name.")
args = parser.parse_args()

SOURCES_DIR = args.sources_dir or "src"

SCRIPT = "https://raw.githubusercontent.com/provizio/coding_standards/master/python/code_standards_enforce.py"  # noqa
urllib.request.urlretrieve(SCRIPT, "code_standards_enforce.py")


subprocess.run(["python", "code_standards_enforce.py", SOURCES_DIR])
