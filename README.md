# Autohook

**Autohook** is a very, _very_ small Git hook manager with focus on automation.

It consists of one script which acts as the entry point for all the hooks, and which runs scripts based on symlinks in appropriate directories.


## Installation

The autohook.sh script can be installed in either of two ways:

1. It can be committed within the Git repo that contains its own hook scripts.  With this method, hook scripts can be committed with the code that they manage, and they match individual branches.
2. It can be copied to a central location with standardized hook scripts.  With this method, hooks scripts are centrally managed and shared among all of the developers who install the autohook.sh script in their environments.

Copy the autohook.sh script to any suitable location, and make it executable.  If you wish it to manage hooks within your Git repository, add it and commit it.  (Whether or not it's committed, it cannot be located within the .git directory tree located in the root of your repository!)

In the directory containing the autohook.sh script, create a directory named "hooks".  Within the "hooks" directory, create directories for each of the Git hooks that are of interest.  (Run the `git help hooks` command to identify the names of the Git hooks.)  These directories will later contain scripts to run in response to the corresponding Git hooks.  For example, within the "hooks" directory, create a child directory named "pre-commit" that will contain scripts that will run before a `git commit` command creates new revisions.  If the "hooks" directory is within your Git repository, add it recursively and commit it.

Set your present working directory to the root of your Git repository.  Invoke the autohook.sh script and give the keyword "install" as its only command line parameter.  Within the repo's .git/hooks directory, this will create symbolic links pointing to the autohook.sh script.  If the autohook.sh script is located within the repo, the links contain relative paths; otherwise they contain fullpaths.  The repo can thus be relocated by way of the "mv" command and still locate the hook scripts.

## Installing Hook Scripts

Write scripts to refine Git's behavior according to the interfaces described by the `git help hooks` command.  Copy the scripts into the appropriate "hooks" child directories as described above.  Make them executable.  If they are in your Git repository, add and commit them.

Some Git hooks supply command line parameters to the hook scripts.  They are duplicated and passed on to all of the hook scripts managed by the autohook.sh script.  The standard input stream is also replicated for each hook script that uses it, as mentioned by the `git help hooks` command.

Hook scripts contained within each of the hook directories run in an arbitrary order that depends on the user's environment.  To standardize the order, we recommend prefixing the name of each hook script with three decimal digits and a hyphen.  They will then run in the sort order of their names.

## Hook Script Search Path

By default, the hook scripts are located in a directory name _prefix_/hooks/_hook-name_ where _prefix_ identifies the location of the autohook.sh script, and _hook-name_ identifies the name of the running Git hook.  This can be changed by setting a search path in the AUTOHOOK_HOOKS_PATH environment variable.  (We do not recommend using this feature if the hook scripts are not centrally managed.)

The search path is a list of directory fullpaths, separated by colons, similarly to the PATH environment variable.  All occurrences of the _%_ character are replaced by the Git hook name.  (It is possible to use relative paths in the AUTOHOOK_HOOKS_PATH setting, but the autohook.sh script's behavior is undefined in this situation and may change in the future.)

For example, setting the AUTOHOOK_HOOKS_PATH environment variable to `/usr/local/lib/git/hook-scripts/%` will cause Git to look for the pre-commit hook scripts in the `/usr/local/lib/git/hook-scripts/pre-commit` directory.

When using the AUTOHOOK_HOOKS_PATH environment variable, all of the specified directories are visited in the order given.


## Examples

### Basic Installation

Let's say you have a script to remove `.pyc` files that you want to run after every `git checkout` and before every `git commit`.  It's named `010-delete-pyc-files`.  And you have another script, named `020-run-tests` to run your test suite before every `git commit`.  You wish to install the `autohook.sh` script in the `/usr/local/lib/git` directory.

Perform the following steps:

1. Copy `autohook.sh` to the /usr/local/lib/git directory and make it executable.
2. Create the /usr/local/lib/git/hooks/post-checkout and /usr/local/lib/git/hooks/pre-commit directories, and make them readable and searchable.
3. Copy the `010-delete-pyc-files` script to the `/usr/local/lib/git/hooks/pre-commit` and `/usr/local/lib/git/hooks/post-checkout` directories.  Copy the `020-run-tests script` to the `/usr/local/lib/git/hooks/pre-commit` directory.  Make them executable.
4. In your Git repository, run `autohook.sh` with the `install` parameter (e.g., `/usr/local/lib/git/autohook.sh install`).

The result should be a tree that looks something like this:

```
/usr/local/lib/git/
├── autohook.sh
└── hooks/
    ├── post-checkout/
    │   └── 010-delete-pyc-files
    └── pre-commit/
        ├── 010-delete-pyc-files
        └── 020-run-tests
```

### Reuse Hook Scripts

To reuse or share hook scripts among multiple Git hooks (and therefore to minimize copies), you can store scripts in a common place.  Use the typical reuse tools such as hard or symbolic links, or short wrapper scripts, to invoke the common sources.

```
/usr/local/lib/git/
├── autohook.sh
└── hooks/
    ├── post-checkout/
    │   └── 010-delete-pyc-files  (symlink to ../scripts/delete-pyc-files)
    ├── pre-commit/
    │    ├── 010-delete-pyc-files (symlink to ../scripts/deleete-pyc-files)
    │    └── 020-run-tests        (symlink to ../scripts/run-tests)
    └── scripts/
        ├── delete-pyc-files
        └── run-tests
```

### Project-Specific Hooks

You can ask your users to set the `AUTOHOOK_HOOKS_PATH` environment variable to define project-specific hooks, or to facilitate reuse in a different way.  In this example, project-x uses Python and requires the `.pyc` files to be removed periodically, while project-y does not.  All projects must run their pre-commit test suites.  We'll have the users add the `all` tree to the end of their search path, after their own projects.

```
/usr/local/lib/git/
├── autohook.sh
└── hooks/
    ├── all
    │   └── pre-commit
    │       └── 020-run-tests
    ├── project-x
    │   └── post-checkout/
    │       └── 010-delete-pyc-files 
    └── project-y
```

A user working on project-x would set their AUTOHOOK_HOOKS_PATH environment variable to this value:  `/usr/local/lib/git/hooks/project-x/%:/usr/local/lib/git/hooks/all/%`

Similarly, a user working on project-x would set their AUTOHOOK_HOOKS_PATH environment variable to this value:  `/usr/local/lib/git/hooks/project-y/%:/usr/local/lib/git/hooks/all/%`

## Contributing

Contributions of all sorts are welcome, be they bug reports, patches, or even just feedback. Creating a [new issue](https://github.com/Autohook/Autohook/issues/new 'New Issue') or [pull request](https://github.com/Autohook/Autohook/compare 'New Pull Request') is probably the best way to get started.

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/Autohook/Autohook/blob/master/CODE_OF_CONDUCT.md 'Autohook Code of Conduct'). By participating in this project you agree to abide by its terms.


## License

This software is licensed under the _MIT License_. Please see the included `LICENSE.txt` for details.