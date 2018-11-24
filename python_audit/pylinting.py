#!/usr/bin/env python

"""Used to quickly audit python code.

About: This file uses 'pylama' code audit tool to identify python code issues.
The main utility of the script is to let a user configure a predefined set of
rules and errors to ignore in their python code; since most programmers have a
set of rules that they usually keep relaxed in their code audits and creating
the complex commands to ignore the rules every time is difficult.

Usage:
1. Modify the file to add/remove any rules or error codes to ignore in your
   python code audits.
2. Grant the file executable permissions.
3. Audit any directory/file containing python code as follows.
     ./pylinting.py <name of file or directory>
4. The results are saved in the file pylama-report.txt.
5. Use the results in the files to improve your python code.

Caveat:
1. This requires 'pylama' to be installed. Refer to
   https://github.com/klen/pylama for installation details.

Credits: https://github.com/klen/pylama
"""

import sys
from pylama.main import check_path, parse_options

my_redefined_options = {
    'linters': ['mccabe', 'pep257', 'pep8', 'pycodestyle', 'pyflakes',
                'pylint', 'radon', 'isort'],
    # 'linters': 'isort',
    'ignore': ['D203', 'D213', 'D406', 'D407', 'D413'],
    # 'select': ['R1705'],
    'sort': 'F,E,W,C,D,R',
    'skip': '*__init__.py,*/test/*.py',
    # 'async': True,
    # 'force': True,
}
my_path = sys.argv[1]

options = parse_options([my_path], **my_redefined_options)
errors = check_path(options, rootdir='.')

print('Total errors before applying ignore rules', len(errors))

c = 0

with open('pylama-report.txt', 'w') as f:
    for e in errors:

        # Define other rules to ignore
        if e.get('number') == 'W0511':
            continue

        # Fields in error object are
        # ['linter', 'col', 'lnum', 'type', 'number', 'filename', 'text']
        s = '%(filename)s:%(lnum)s:%(col)s: %(text)s\n' % e
        c += 1
        f.write(s)

print('Total errors after applying ignore rules', c)
