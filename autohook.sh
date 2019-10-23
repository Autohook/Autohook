#!/usr/bin/env bash

# Autohook
# A very, very small Git hook manager with focus on automation
# Author:   Nik Kantar <http://nkantar.com>
# Version:  2.1.1
# Website:  https://github.com/nkantar/Autohook

echo() {
  builtin echo "[Autohook] $@"
}

install() {
  hook_types=(
    "applypatch-msg"
    "commit-msg"
    "post-applypatch"
    "post-checkout"
    "post-commit"
    "post-merge"
    "post-receive"
    "post-rewrite"
    "post-update"
    "pre-applypatch"
    "pre-auto-gc"
    "pre-commit"
    "pre-push"
    "pre-rebase"
    "pre-receive"
    "prepare-commit-msg"
    "update"
  )

  repo_root="$(git rev-parse --show-toplevel)"
  hooks_dir="$repo_root/.git/hooks"
  cd "${0%/*}"
  autohook_linktarget="$(pwd)/autohook.sh"
  echo "$autohook_linktarget"

  for hook_type in "${hook_types[@]}"; do
    hook_symlink="$hooks_dir/$hook_type"
    ln -sf "$autohook_linktarget" "$hook_symlink"
  done
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
  if [[ "${AUTOHOOK_hook_dirs=''}" != '' ]]; then
    readarray -t -d':' hook_dirs <<<"${AUTOHOOK_HOOKS_DIR}"
    hook_dirs[-1]="${hook_dirs[-1]%$'\n'}"
  else
    hook_dirs=("$repo_root/hooks/")
  fi

  local -a files
  for dir in "${hook_dirs[@]/%//$hook_type}"; do
    files+=("$dir"/*)
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

    for file in "${files[@]}"; do
      scriptname="$(basename "$file")"
      echo "BEGIN $scriptname"
      eval "'$file'"
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
}

main "$@"
