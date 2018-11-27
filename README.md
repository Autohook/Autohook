# Autohook

**Autohook** is a very, _very_ small Git hook manager with focus on automation.

It consists of one script which acts as the entry point for all the hooks, and which runs scripts based on symlinks in appropriate directories.

[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/nkantar)


## Example

Let's say you have a script to remove `.pyc` files that you want to run after every `git checkout` and before every `git commit`, and another script that runs your test suite that you want to run before every `git commit`.

Here's the overview of steps:

1. Install `autohook.sh` to a directory of your liking.
2. Put your scripts in:
  - alternative 1: `hooks/scripts/` next to the `autohook.sh` script.
  - alternative 2: a custom directory pointed to by the `AUTOHOOK_HOOKS_DIR` environment variable
3. Make sure said scripts are executable (e.g., `chmod -R +x hooks/`)
4. Run `autohook.sh` with the `install` parameter (e.g., `./autohook.sh install`).
5. Make directories for your hook types (e.g., `mkdir -p hooks/post-checkout hooks/pre-commit`).
6. Symlink your scripts to the correct directories, using numbers in symlink names to enforce execution order (e.g., `ln -s hooks/scripts/delete-pyc-files.sh hooks/post-checkout/01-delete-pyc-files`, etc.).
  - Alternatively, you could place your scripts directly under `hooks/post-checkout`, etc

The result should be a tree that looks something like this:

```
repo_root/
├── hooks/ OR $AUTOHOOK_HOOKS_DIR/
│   ├── post-checkout/
│   │   └── 01-delete-pyc-files     # symlink to hooks/scripts/delete-pyc-files.sh
│   ├── pre-commit/
│   │   ├── 01-delete-pyc-files     # symlink to hooks/scripts/delete-pyc-files.sh
│   │   └── 02-run-tests            # symlink to hooks/scripts/run-tests.sh
│   └── scripts/
│       ├── delete-pyc-files.sh
│       └── run-tests.sh
├── other_dirs/
└── other_files
```

You're done!


## Contributing

Contributions of all sorts are welcome, be they bug reports, patches, or even just feedback. Creating a [new issue](https://github.com/nkantar/Autohook/issues/new 'New Issue') or [pull request](https://github.com/nkantar/Autohook/compare 'New Pull Request') is probably the best way to get started.

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/nkantar/Autohook/blob/master/CODE_OF_CONDUCT.md 'Autohook Code of Conduct'). By participating in this project you agree to abide by its terms.


## License

This software is licensed under the _MIT License_. Please see the included `LICENSE.txt` for details.
