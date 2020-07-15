#!/usr/bin/env bash

echo_run_cmd () {
    printf ">> \e[36m%s\e[0m\n" "$*"
    "$@"
}

cwd=$PWD
output_file="$cwd/git_deleted_repos.sh"
chmod +x "$output_file"

dirs=$( find . -type d -name '.git' )

while read -r dir; do
    dir=${dir%.git}
    cd "$dir"
    printf "\nIn directory \e[33m%s\e[0m\n" "$PWD"

    echo_run_cmd git status
    echo_run_cmd git stash list | grep ''
    echo_run_cmd git branch -avv | grep ''
    remote_url=$( git config --get remote.origin.url )

    read -rp "Remove [y/N]? " ans </dev/tty

    cd "$cwd"
    if [ "$ans" == 'y' ] || [ "$ans" == 'Y' ]; then
        rm -rf "$dir"
        echo "git clone $remote_url $dir" >> "$output_file"
        printf "\e[31;1mRemoved '%s'\e[0m\n" "$dir"
    fi
done <<< "$dirs"
