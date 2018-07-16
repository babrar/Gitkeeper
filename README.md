# Git Template Implementation in Perl
Git extension (hook) for maintaining code consistency in larger shared repositories with multiple contributors.

## Preface
A large repository with multiple contributors on different IDEs and Operating Systems has the potential to introduce problems related to non-uniformity of code. Debugging an issue caused by a rogue space/tab or a subtle file mode change can take several hours to fix, costing contributors valuable time.

*Gitook* is an implementation of [Git Template](https://git-template.readthedocs.io) and is designed to aid in minimizing such inconsistencies.

## Instructions
**Setup**
```sh
# run from your repo root
$ git clone https://github.com/babrar/Gitook.git
$ cd Gitook
$ make
```
This will initialize all git-hooks and dependencies. You can now make changes to your local repo. Once changes are ready to be committed,
the git-hook will be invoked every time `git commit` is called and, any undesired changes to the repo will be rejected.

To **bypass** the hook, run git commit with the `--no-verify` option as shown.
```sh
$ git commit -m "don't check me out" --no-verify
```
**Uninstall**

To permananently uninstall hooks, `cd` into Gitook and run
```sh
$ make uninstall
```
**View Log**

*Gitook* also comes with a built-in logger. To view run summary or errors `cd` into Gitook and run
```sh
$ make report # view run summary
# OR
$ make error # view error log
```
## Specifications
*Pre-commit.pl*
checks and blocks commits that contain (as of last update) :
- Binary files
- Oversized files
- Tabs in source files --> Hard error. Program outputs and exits right away
- Unexpected file-mode changes

The script *initrepo.sh* is designed to initialize all dependencies .
When run (through the Makefile), *initrepo.sh* :
- Sets up [Git Template](https://git-template.readthedocs.io).
- Downloads all necessary hooks from this repository and initializes them in .git_template folder.
- Adds all components from Gitook to user's *.gitignore*
i.e.
```sh
Gitook/
initrepo.sh
```

**Supported Languages** : C, C++, Python, Java, JavaScript, Go, Perl, Shell

## Limitation

Gitook relies on non-space-delimited file and directory names for functionality. Therefore it will not be compatible with repositories containing space-delimited files and/or directories.


## Examples
**Source files with tabs** (i.e. files of only Supported Languages)
```sh
$ git commit -m "Commiting file containing tabs"
tab_file.py @1: this file has   # prints line number
ERROR: Tabs found in files listed above. Commit Aborted.
Please replace the tabs with spaces.
To force the commit, bypass this error by re-running your commit with the '--no-verify' option
```
**Binary files**
```sh
$ git commit -m "Binary file"
WARNING: binary_file is binary.
Please check with repo owner before committing binary files.
Commit aborted.
To force the commit, bypass this error by re-running your commit with the '--no-verify' option
```

**Oversized files**
```sh
$ git commit -m "Oversized file"
WARNING: BigFile is greater than 1000000 bytes.
Please check with repo owner before committing very large files.
Commit Aborted
To force the commit, bypass this warning by re-running your commit with the '--no-verify' option
```
## Contributing

Bug reports and pull requests are welcome on GitHub at [@babrar](https://www.github.com/babrar).

## Author

Banin Abrar: [E-mail](mailto:baninabrar98@gmail.com), [@babrar](https://www.github.com/babrar)

## License

The project is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT)
