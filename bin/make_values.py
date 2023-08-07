#!/usr/bin/env python3

import re
import sys
import yaml
from typing import TextIO


def set_value(values: dict, key:str, value:str) -> None:
    parts = key.split('.')
    current = values
    for part in parts[:-1]:
        key = part.replace('"', '').replace('__', ".")
        if not key in current:
            # print(f"Creating dict for {key}")
            current[key] = {}
        current = current[key]
    key = parts[-1].replace('"', '').replace('__', ".")
    current[key] = re.sub(r'\${{\s*(\w+\.)*(\w+?)\s*}}', r'{{ \g<2> }}', value).lower() #.replace('"', '')
    # print(f"{key}={value}")
    # while '.' in current_key:

def run(istream:TextIO):
    values = {}
    for line in istream.read().splitlines():
        kv = line.strip()\
            .replace('--set ', '')\
            .replace("\\.", "__")\
            .replace('\"', '"')\
            .replace("\\", "")
        key,value = kv.split("=")
        # print(f"{key} = {value}")
        set_value(values, key, value)
    output = yaml.safe_dump(values)
    print(output.replace("'", ""))


if __name__ == '__main__':
    istream = sys.stdin
    close_stream = False
    if len(sys.argv) > 1:
        istream = open(sys.argv[1])
        close_stream = True
    try:
        run(istream)
    finally:
        if close_stream:
            istream.close()