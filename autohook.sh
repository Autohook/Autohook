#!/usr/bin/env bash

# Autohook
# A very, very small Git hook manager with focus on automation
# Contributors:   https://github.com/Autohook/Autohook/graphs/contributors
# Version:        2.3.0
# Website:        https://github.com/Autohook/Autohook


echo() {
    builtin echo "[Autohook] $@";
}

# Set up a temporary file and delete it automatically upon exit.

if [[ "x$TMPDIR" = "x" ]]
then
    export TMPDIR="/tmp"
fi
tmpfile="${TMPDIR}/$(basename "$0").$$"

cleanup() {
    rm -f "$tmpfile"
}

trap cleanup 0

# These hooks don't read stdin.
hook_types=(
    "applypatch-msg"
    "commit-msg"
    "fsmonitor-watchman"
    "p4-pre-submit"
    "post-applypatch"
    "post-checkout"
    "post-commit"
    "post-index-change"
    "post-merge"
    "post-update"
    "pre-applypatch"
    "pre-auto-gc"
    "pre-commit"
    "pre-merge-commit"
    "pre-rebase"
    "prepare-commit-msg"
    "push-to-checkout"
    "sendemail-validate"
    "update"
)

# These hooks read stdin.
hook_types_stdin=(
    "pre-push"
    "pre-receive"
    "post-receive"
    "post-rewrite"
)

# Install the hooks.

install() {
    repo_root=$(git rev-parse --show-toplevel)
    hooks_dir="$repo_root/.git/hooks"
    autohook_linktarget="../../hooks/autohook.sh"
    for hook_type in "${hook_types[@]}" "${hook_types_stdin[@]}"
    do
        hook_symlink="$hooks_dir/$hook_type"
        ln -sf $autohook_linktarget $hook_symlink
    done
}

# Determine if the given hook reads stdin.  Return 0 if yes.

reads_stdin() {
    [[ "x ${hook_types_stdin[*]} " = x*" $1 "* ]]
    return $?
}

main() {
    calling_file=$(basename $0)

    if [[ $calling_file == "autohook.sh" ]]
    then
        command=$1
        if [[ $command == "install" ]]
        then
            install
        fi
    else
        repo_root=$(git rev-parse --show-toplevel)
        if [[ "x$(basename "$repo_root")" = x.git ]]
        then
            repo_root="$(dirname "$repo_root")"
        fi
        hook_type=$calling_file
        symlinks_dir="$repo_root/hooks/$hook_type"
        files=("$symlinks_dir"/*)
        number_of_symlinks="${#files[@]}"
        if [[ $number_of_symlinks == 1 ]]
        then
            if [[ "$(basename ${files[0]})" == "*" ]]
            then
                number_of_symlinks=0
            fi
        fi
        echo "Looking for $hook_type scripts to run...found $number_of_symlinks!"
        if [[ $number_of_symlinks -gt 0 ]]
        then
            if reads_stdin "$calling_file"
            then
                cat - > "$tmpfile"
            fi
            hook_exit_code=0
            for file in "${files[@]}"
            do
                scriptname=$(basename $file)
                echo "BEGIN $scriptname"
                if reads_stdin "$calling_file"
                then
                    "$file" < "$tmpfile"
                else
                    "$file"
                fi
                script_exit_code=$?
                if [[ $script_exit_code != 0 ]]
                then
                  hook_exit_code=$script_exit_code
                fi
                echo "FINISH $scriptname"
            done
            if [[ $hook_exit_code != 0 ]]
            then
              echo "A $hook_type script yielded negative exit code $hook_exit_code"
              exit $hook_exit_code
            fi
        fi
    fi
}


main "$@"
