#!/usr/bin/env bash -eu

# Autohook
# A very, very small Git hook manager with focus on automation
# Contributors:   https://github.com/Autohook/Autohook/graphs/contributors
# Version:        2.3.0
# Website:        https://github.com/Autohook/Autohook

debugging=1
debug() {
  if [[ $debugging -ne 0 ]]; then
    builtin echo "[Autohook debug] $@" 1>&2
  fi
}

echo() {
  builtin echo "[Autohook] $@" 1>&2
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
  repo_root="$(git rev-parse --show-toplevel)"
  hooks_offset=".git/hooks"
  hooks_dir="$repo_root/$hooks_offset"
  autohooksh_dir="$( cd "${0%/*}"; pwd )"
  if [[ "x$autohooksh_dir" = "x$hooks_dir" ]]; then
    echo "Do not install the $(basename "$0") script in the $hooks_offset"
    echo "directory of a Git repository."
    exit 1
  fi
  if [[ "x$autohooksh_dir" = "x$repo_root" || \
        "x$autohooksh_dir" = "x$repo_root"/* ]]; then
    # autohook.sh is in the same repo.  Symlinks contain relative paths
    # so that the user can mv the repo and hooks will continue to work.
    autohook_linktarget="../..${autohooksh_dir#$repo_root}/autohook.sh"
  else
    # autohook.sh is outside the repo.  Symlinks contain fullpaths to it.
    autohook_linktarget="${autohooksh_dir}/autohook.sh"
  fi

  for hook_type in "${hook_types[@]}" "${hook_types_stdin[@]}"; do
    hook_symlink="$hooks_dir/$hook_type"
    ln -sf "$autohook_linktarget" "$hook_symlink"
  done
}

# Determine if the given hook reads stdin.  Return 0 if yes.

reads_stdin() {
  [[ "x ${hook_types_stdin[*]} " = x*" $1 "* ]]
  return $?
}

main() {
  calling_file="$(basename "$0")"

  if [[ "$calling_file" == "autohook.sh" ]]; then
    command="$1"
    if [[ "$command" == "install" ]]; then
            install
    fi
    return
  fi

  repo_root="$(git rev-parse --show-toplevel)"
  hook_type="$calling_file"

  local -a hook_dirs
  local hpth
  if [[ "x${AUTOHOOK_HOOKS_DIR:-}" = 'x' ]]; then
    autohook_path=$(readlink -f "$0")
    export AUTOHOOK_HOOKS_DIR="$( dirname "$autohook_path" )/hooks/%"
  fi
  debug "Hook directories identified by AUTOHOOK_HOOKS_DIR"
  debug ">$AUTOHOOK_HOOKS_DIR<"

  # Convert colon-separated search path in $AUTOHOOK_HOOKS_DIR to
  # an array of directories in ${hook_dirs[@]}, replacing empty entries
  # with the present working directory.
  # Work around the absence of the readarray command in some modern systems.
  # The 1st sed escapes spaces and tabs with backslashes!

  hpth=$( sed -e 's/[ 	]/\\&/g' <<<"$AUTOHOOK_HOOKS_DIR" |
          sed  -e 's/^:/.:/' -e 's/::/:.:/g' -e 's/:$/:./' -e 's/:/ /g' )
  read -a hook_dirs <<<"$hpth"

  debug "$hook_type hook directories:"
  for hd in "${hook_dirs[@]}"; do
    debug "    $hd"
  done

  local -a files
  for pdir in "${hook_dirs[@]}"; do
    dir="${pdir//\%/$hook_type}"
    debug "Looking for $hook_type hooks in $dir"
    if [[ -d "$dir" ]]; then
      files+=("$dir"/*)
    fi
  done

  number_of_hooks="${#files[@]}"
  if [[ "$number_of_hooks" == 1 ]]; then
    if [[ "$(basename "${files[0]}")" == "*" ]]; then
      number_of_hooks=0
    fi
  fi

  echo "Looking for $hook_type scripts to run...found $number_of_hooks!"

  if [[ "$number_of_hooks" -gt 0 ]]; then
    local hook_exit_code=0
    local failed_hook=''

    if reads_stdin "$hook_type"; then
      cat - > "$tmpfile"
    fi

    for file in "${files[@]}"; do
      scriptname="$(basename "$file")"
      echo "BEGIN $scriptname"

      if reads_stdin "$hook_type"; then
        "$file" < "$tmpfile"
      else
        "$file"
      fi

      script_exit_code="$?"
      if [[ "$script_exit_code" != 0 ]]; then
        hook_exit_code="$script_exit_code"
        failed_hook="$file"
      fi
      echo "FINISH $scriptname"
    done

    if [[ "$hook_exit_code" != 0 ]]; then
      echo "The $hook_type script '${failed_hook##*/$hook_type/}' yielded negative exit code $hook_exit_code"
      exit "$hook_exit_code"
    fi
  fi
  exit 0
}

main "$@"
