#!/usr/bin/env bash

# Autohook
# A very, very small Git hook "framework".
# Author:   Nik Kantar <http://nkantar.com>
# Version:  1.0.0
# Website:  https://github.com/nkantar/Autohook

hook=$(basename $0)
repo_root=$(git rev-parse --show-toplevel)

scripts_dir="$repo_root/hooks"
files=($scripts_dir/*)

for file in "${files[@]}"
do
    script=$(basename $file)
    if [[ $script == $hook* ]]
    then
        eval $file
    fi
done

