# Git Template Implementation (Perl)
Git extension (hook) for maintain code consistency in larger shared repositories with multiple contributors.

## Preface
A large repository with multiple contributors on  different IDEs and Operating Systems has the potential to introduce problems related to non-uniformity of code. Debugging an issue caused by a rogue space/tab or a subtle file mode change can take several hours to fix, costing contributors valuable time.

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
**.gitignore**
Add the following lines to the .gitignore of your repo, to stop Gitook being pushed alongside your repository
```
Gitook/
initrepo.sh
```

## Specifications
**Pre-commit**
Checks and blocks commits that contain (as of last update) :
- Binary files
- Oversized files
- Tabs in source files
- Unexpected file-mode changes

Supported Languages : C, C++, Python, Java, JavaScript, Go, Perl, Shell

The script *initrepo.sh* is designed to initialize all dependencies .
When run, *initrepo.sh* :
- Sets up [Git Template](https://git-template.readthedocs.io).
- Downloads all necessary hooks from this repository and initialize them in .git_template folder.

## Known Issues
Commands involving curl sometimes freeze inside SourceTree's *MINGW32* Terminal. As a result init_repo.sh may seem to become unresponsive.
If faced with such an issue, run init_repo.sh with the `--winpty` option as shown below.
 ```sh
$ ./init-repo.sh --winpty
 ```
**Limitation**
Gitook relies on non space-delimited file and directory names. Therefore it will not be compatible with repositories containing space-delimited files and/or directories.
## Contributing

Bug reports and pull requests are welcome on GitHub at [@babrar](https://www.github.com/babrar)
Gitook comes with a logger. To view run summary or errors `cd` into Gitook and run
```sh
$ make report # view run summary
# OR
$ make error # view error log
```

## Author

Banin Abrar: [E-mail](baninabrar98@gmail.com), [@babrar](https://www.github.com/babrar)

## License

The project is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT)
