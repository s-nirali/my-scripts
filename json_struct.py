#!/usr/bin/env python

# TODO: make struct with counts of each line's use in the JSON
# TODO: make struct with list of all it's values types
# TODO: print possible values ??? - only for basic types, limit string lengths
# TODO: list of non dictionaries

import json, sys

with open(sys.argv[1]) as f:
    data = json.load(f)

def pprint(key, data, level):
    # print("debug: key", key, json.dumps(data, indent=2))
    typ = type(data[key]).__name__
    print('\t'*level + key + ': ' + typ)
    return typ

def match_and_merge(original_struct, new_struct):
    for key in new_struct:
        # print("debug: ori_str", original_struct, ", new_str", new_struct, ", key", key)
        if key in original_struct:
            # if original_struct[key][0] != new_struct[key][0]:
            #     print('Error', '; Key:', key, '; new_struct:', new_struct[key], '; original_struct:', original_struct[key])
            #     exit(1)
            if original_struct[key][0] in ['dict', 'list']:
                original_struct[key][1] = match_and_merge(original_struct[key][1], new_struct[key][1])
        else:
            original_struct[key] = new_struct[key]
    return original_struct

def gettypes(data, level):
    structure = {}
    for key in data:
        substruct = None
        typ = pprint(key, data, level)
        if typ == 'dict':
            substruct = gettypes(data[key], level + 1)
        elif typ == 'list':
            prestruct = {}
            for i in data[key]:
                print('\t'*level + '-')
                if isinstance(i, dict):
                    substruct = gettypes(i, level + 1)
                else:
                    substruct = {'0': [type(i).__name__, None]}
                prestruct = match_and_merge(prestruct, substruct)
            substruct = prestruct

        if key in structure:
            if structure[key][0] != typ:
                print('Error', '; Key:', key, '; Type:', typ, '; Existing key type:', structure[key])
                exit(1)
            if substruct:
                substruct = match_and_merge(structure[key][1], substruct)
        structure[key] = [typ, substruct]

    # print("debug: return structure", structure)
    return structure

structure = gettypes(data, 0)

print('--------\n')
rstctl = '\u001b[0m'
def pprint_struct(structure, level):
    for key in structure:
        ctl = rstctl if level%7 == 0 else '\u001b[3' + str(level%7) + 'm'
        print(ctl + '\t'*level + key + ': ' + structure[key][0] + rstctl)
        if structure[key][1] is not None:
            pprint_struct(structure[key][1], level + 1)
pprint_struct(structure, 0)
