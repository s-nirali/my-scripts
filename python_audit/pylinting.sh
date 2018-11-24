#!/usr/bin/env bash

: <<'END_COMMENT'
About: This file may be used for quickly auditing python code. It uses the
'pylama' code audit tool to identify python code issues. The main utility of the
script is to let a user configure a predefined set of regexes and errors to
ignore in their python code; since most programmers have a set of rules that
they usually keep relaxed in their code audits and creating the complex command
to ignore the rules every time is difficult.

Usage:
1. Modify the file to add/remove any regexes or error codes to ignore in your
   python code audits.
2. Grant the file executable permissions.
3. Audit any directory/file containing python code as follows.
     ./pylinting.sh <name of file or directory>
4. The results are saved in 2 files: pylama-report.txt and
   pylama-report.txt.bkp. 'pylama-report.txt' contains the results after removal
   of the regexes whereas the backup file contains the results after ignoring
   the errors alone.
5. Use the results in the files to improve your python code.

Caveat:
1. This file works best on OSX. The commands might have to be tweaked for
   Linux/Unix systems.
2. This requires 'pylama' to be installed. Refer to
   https://github.com/klen/pylama for installation details.

Credits: https://github.com/klen/pylama
END_COMMENT

report='pylama-report.txt'
dir="$1"

# Define regexes to remove
declare -a regexes=(
'.*__init__\.py:1:1: D104 Missing docstring in public package \[(pep257|pydocstyle)\]'
'.*/test/.*\.py:.*: D10[0123] Missing docstring in public (class|module|method) \[(pep257|pydocstyle)\]'
'.*/test/.*\.py:.*: C0111 Missing (method|class) docstring \[pylint\]'
'.*/test/.*\.py:.*: D107 Missing docstring in __init__ \[(pep257|pydocstyle)\]'
'.* W0511 TODO: .* \[pylint\]'
)

# The 2 variables below include errors and warning codes
conflicting_errors='D203,D213,D406,D407,D413'
other_errors=''

# Skip files with masks
skip_mask='*__init__.py,*/test/*.py'

# Run pylama
pylama -l mccabe,pep257,pep8,pycodestyle,pyflakes,pylint,radon,isort "$dir" -r "$report" -i "$conflicting_errors,$other_errors" --sort 'F,E,W,C,D,R' --skip "$skip_mask"
cp "$report" "$report".bkp
lc1=$( wc -l <"$report" )

search_and_count () {
  grep -E "$1" "$report" -c
}

find_and_remove () {
  sed -i '' -E "s/${1//\//\\/}//g" "$report"
}

# Count number of occurances of each regex in array regexes and remove them
echo -e "\\e[1mCount\\tPattern\\e[0m"
for i in "${regexes[@]}"
do
  n=$( search_and_count "$i" )
  echo -e "$n\\t$i"
  find_and_remove "$i"
done

# Remove empty lines from the file
sed -i '' /^$/d "$report"
lc2=$( wc -l <"$report" )

echo
echo -e "Total number of lines in $report before cleanup:\\t$lc1"
echo -e "Total number of lines in $report after cleanup:\\t$lc2"
