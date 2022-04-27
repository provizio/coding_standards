

# Python Coding Standards Repo

This repository serves as a reference for a standard python package/project within Provizio. It contains sample files 
such as:
- setup.py
- requirements.txt
- tox.ini
- etc.

More details on the Python coding standards used in Provizio can be found on the Confluence page:
https://provizio.atlassian.net/wiki/spaces/PROVIZIO/pages/839155743

## Checking compliance with Coding Standards

Usage: <br/>

To check compliance with the Provizio Python coding standards, simply download
and place the script `coding_standards_check.py` inside the root folder of your project.

Run the script with one argument - the sources folder.

e.g.
```shell
python coding_standards_check.py src
```

**The script will download necessary files to perform all checks.**

<br/>

### Project Folder Layout

A project folder should have the following layout in general (from root/):

```README.md 
---/ 
    LICENSE (in case of open-source code)
    .gitignore
    setup.py 
    requirements.txt
    docs/index.md   
    tests/test_modname.py
    modname/__init__.py
    modname/somemode.py
    modname/somehelper.py
```

### Code Style
It is required that all python code follows PEP8 style guide.
It is recommended that python code follows Google's pyguide code style guidelines.

Refer to [Coding Standards](https://provizio.atlassian.net/wiki/spaces/PROVIZIO/pages/839155743
) page in Provizio's Confluence, for more info on the code style requirements.



### Packaging
It is highly recommended to use setuptools for packaging and deployment. A sample `setup.py` file is included in this repo
for reference. 

### Environments
It is recommended to use Conda (Miniconda or Anaconda) package manager for virtual environments.


### Testing
Unit tests are recommended to be part of any python project/package. The frameworks unittest
or pytest can be used both.

Unit testing provides some major benefits over ad-hoc testing:

- Enables you to discover bugs immediately
- Prevents regressions (when fixing a bug, always create a test for the case that triggered the bug)
- Improves code quality
- Facilitates changes and refactoring (you can be confident that you didn't break something during a refactor)

A recommended test suite is tox which allows automated testing and includes additional advanced features
such as including flake8 checks.

This repo includes a sample `tox.ini` file that is required by tox as a description of the process.
Tox allows to run tests in many different environments that are listed in the `tox.ini` file.

### Git
A python .gitignore file is included in this repo as a reference.

In Provizio we use git (and Github) for code management. Contributions are done via pull requests (PRs).

A general guideline for using git includes the following few basic rules:

- Create branches for all development
- Commit frequently
- Clean up/delete stale branches after merges
- Use descriptive commit messages
- Use pull requests to test code before merging to master repository.
- (Optional) Include JIRA ticket number in PR names

More detailed best practices for git can be found [here](https://sethrobertson.github.io/GitBestPractices/).


### CI/CD

TODO: