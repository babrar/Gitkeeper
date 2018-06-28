## Pre-commit
Executed every time `git commit` is called and checks for undesired changes to local repo.

Checks and blocks commits that contain (as of last update) :
- Binary files
- Oversized files
- Tabs (YES!)
- Unexpected file-mode changes
- Specified confidential information

## init-repo
Designed to initialize all dependencies .

When run, init_repo :
- Sets up [Git Template](https://git-template.readthedocs.io).
- Downloads all necessary hooks from this repository and initialize them in .git_template folder.
