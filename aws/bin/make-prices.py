#!/usr/bin/env python3
import io
import json
import sys
import csv
import yaml

from pprint import pprint

def by_config(a):
    v = a.split('x')
    return (float(v[0]), float(v[1]))


def run(path):
    matrix = {}
    types = []
    configs = []
    with open(path) as f:
        data = csv.reader(f)
        for row in data:
            type = row[1]
            config = f"{row[2]}x{row[3]}"
            cost = row[4]
            if type not in matrix:
                matrix[type] = {}
                types.append(type)
            if config not in configs:
                configs.append(config)
            matrix[type][config] = cost
    print(json.dumps(matrix, indent=4))
    # configs = sorted(configs, key=by_config)
    # print(f"Instance,{','.join(configs)}")
    # for type in types:
    #     print(f"{type}", end='')
    #     for config in configs:
    #         price = '0.0'
    #         if config in matrix[type]:
    #             price = matrix[type][config]
    #         # price = matrix[type][config]
    #         print(f",{price}", end='')
    #     print()

        
if __name__ == '__main__':
    run(sys.argv[1])