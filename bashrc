#!/usr/bin/env bash

: <<'END_COMMENT'
About: The contents of this file may be used to quickly set up a Linux/Unix/OSX
terminal environment.

Usage:
1. Name this file ".bashrc".
2. Move it to the home directory in the system.
3. Make sure to add the following line in the file "~/.bash_profile"
     source ~/.bashrc

Caveat:
1. This file works best on OSX. The commands might have to be tweaked for
   Linux/Unix systems.
2. Some commands, functions or variables require other tools to be present and
   installed. In most cases, the tools are obtained using `brew install`.

Credits: Stack Exchange
END_COMMENT

### ---Bash functions---

## Get weather
getweather ()
{
  # change Bangalore to your default location
  curl -H "Accept-Language: ${LANG%_*}" wttr.in/"${1:-Bangalore}"

  # Uncomment to get only current weather
  # curl wttr.in/"${1:-Bangalore}"?0Qp
}

## Set public git repo credentials
setgit ()
{
  # The first function argument may be used to change the name
  git config --local --add user.name "${1:-example-username}"
  # The second function argument may be used to change the email
  git config --local --add user.email "${2:-email@example.com}"
}

## Get emoji based on time
get_time_emoji ()
{
  [[ "$( date '+%H:%M:%S' )" > "15:35:00" ]] &&
    [[ "$( date '+%H:%M:%S' )" < "16:00:00" ]] &&
    echo ' 🚗 '
}

## Get git branch in '(<branch_name>)' format
get_git_br ()
{
  br=$( git branch 2>/dev/null | grep '\* ' | cut -d' ' -f2 )
  [ -n "$br" ] && echo "($br)"
}

## Set Volume
vo () {
  # First argument is an integer for the output volume level
  osascript -e "set volume output volume $1"
}

## Color stderr
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[91m&\e[m,'>&2)3>&1
## Color stderr, time the output and alert when completed
cta ()
{
  # Usage: The prefix 'cta' or 'color' may be used before any other normal bash
  # command. Prefix 'cta' may be used before running programs that might take a
  # long time to complete as it sends an alert signal in the end.
  color time "$@";
  printf '\a'
}

## Generate a string of random characters
getpass ()
{
  # About: Used to generate passwords for any application.
  # Usage: The function generates a string of default length 15 chars. Set the
  # first argument to override the default length of 15 chars and second
  # argument to override the default number of passwords generated.

  # For OSX, tr complains of 'Illegal byte sequence' if LC_ALL=C is not used
  LC_ALL=C </dev/urandom tr -dc '[:print:]' | fold -w "${1:-15}" | head -n "${2:-1}"
}
## Generate a string of random characters and copy to clipboard
getpassp ()
{
  # About: Generates a string of random characters using the getpass() function
  # and directly copies it to clipboard without displaying on stdout.
  getpass "$@" | pbcopy # for OSX
}

## Clean up python compiled and cache files
pyclean ()
{
  find . -name "__pycache__" -exec rm -r {} +
  find . -name "*.pyc" -exec rm {} +
}

## Perform a full search for a path with a particular string in it
fullsrch ()
{
  # Usage: The first argument is the string to search. The optional second
  # argument is to override the default path to search in.
  sudo find "${2:-/}" -iname "*$1*" 2>/dev/null
}

## Create a simple secure netcat chat server
scon ()
{
  # Usage: The server serves on the default port 9999, which can be overriden by
  # passing the port as a parameter to the function. Share the server IP with
  # other users who can chat using the following command
  #   ncat <IP> <port> --ssl

  # 'ncat' comes bundled with 'nmap' which may be installed using brew.
  echo 'Serving on default port 9999...'
  ncat -vl --ssl --chat "${1:-9999}"
}

### ---Aliases---

# Turn off volume
alias voff="osascript -e \"set Volume 0\""

# Clear terminal and scroll
alias cterm="clear && printf '\\e[3J'"

alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
alias ll='ls -lAG' # for OSX

# Install shellcheck(https://github.com/koalaman/shellcheck) with brew
alias shellcheck='shellcheck -axs bash'

### ---Bash variables---

## Set bash prompt
# Colored PS1
PS1='\[\e[1;35m\]\u@\h\[\e[0m\] \[\e[1m\]\t \[\e[34m\]\W $(get_git_br)$(get_time_emoji)\$ \[\e[0m\]'
# Plain PS1
# PS1='\[\e[1m\]\u@\h \t \[\e[0m\]\W $(get_git_br)$(get_time_emoji)\$ '

# Ignore duplicates and commands starting with space in bash history file
export HISTCONTROL=ignoreboth

export HISTFILESIZE=1000
export PYTHONDONTWRITEBYTECODE=1
