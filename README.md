# Git Template Implementation (Perl)
Git extension (hook) for maintain code consistency in larger shared repositories with multiple contributors.

## Preface
A large repository with multiple contributors on  different IDEs and Operating Systems has the potential to introduce problems related to non-uniformity of code. Debugging an issue caused by a rogue space/tab or a subtle file mode change can take several hours to fix, costing contributors valuable time.

*Gitook* is designed to be an extension of git and aid in minimizing such inconsistencies.

## Instructions
```sh
# run from your repo root
$ git clone https://github.com/babrar/build_support_scripts.git
$ cd build_support_scripts
$ make
$ cd ..
$ ./init-repo.sh
```
This will initialize all git-hooks and dependencies. You can now make changes to your local repo. Once changes are ready to be committed,
the git-hook will be invoked every time `git commit` is called and, any undesired changes to the repo will be rejected.

To bypass the hook, run git commit with the `--no-verify` option as shown.
```sh
git commit -m "don't check me out" --no-verify
```
## Specifications
See hook specifications @ [SPECS.md](https://github.com/babrar/build_support_scripts/blob/master/SPECS.md)

## Known Issues
Commands involving curl sometimes freeze inside SourceTree's *MINGW32* Terminal. As a result init_repo.sh may seem to become unresponsive.
If faced with such an issue, run init_repo.sh with the `--winpty` option as shown below.
 ```sh
$ ./init-repo.sh --winpty
 ```
 ## Disclaimer

Purely experimental project. Designed for learning purposes not production use.

## Contributing

Bug reports and pull requests are welcome on GitHub at [@babrar](https://www.github.com/babrar)

## Author

Banin Abrar: [E-mail](baninabrar98@gmail.com), [@babrar](https://www.github.com/babrar)

## License

The project is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT)
