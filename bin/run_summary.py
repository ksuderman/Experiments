#!/usr/bin/env python3

import io
import sys
from pprint import pprint

# Run,Cloud,Job Conf,Workflow,History,Inputs,Tool,Tool Version,State,Slots,Memory,Runtime (Sec),CPU,Memory Limit (Bytes),Memory Max usage (Bytes)

keys = "Run,Cloud,Conf,Workflow,History,Inputs,Tool,Version,State,Slots,Memory,Runtime,CPU,Limit,Memory".split(',')
n_keys = len(keys)

size_map = {
    "EBI SRA: ERR3988762_2": 4,
    "ERR015526_2.fastq.gz": 2,
    "SRR592109_2.fastq.gz": 1
}

size_tranlate = ['   ', 'S  ', ' M ', 'SM ', '  L', 'S L', ' ML', 'SML']

header = '1x4,1x8,1x16,2x8,2x16,4x8,4x16,6x16,7x15,8x16,16x32'

instance_map = dict()

def fill_map(type, instances):
    for i in instances:
        instance_map[i] = type

fill_map('GCP', ['c2', 'e2', 'n1', 'n2'])
fill_map('EKS', ['m5', 'm5a', 'm5n', 'c6i', 'm6i'])
instance_map['js1'] = 'JS1'
instance_map['js2'] = 'JS2'

def parse_line(line:str):
    result = dict()
    values = line.split(',')
    if n_keys != len(values):
        print("Invalid line:")
        print(line)
        sys.exit(1)

    for i in range(0, n_keys):
        key = keys[i]
        result[key] = values[i]

    return result


def p(s):
    print(s, end='')


def run():
    with open('results/all.csv', 'r') as f:
        lines = f.readlines()

    matrix = dict()
    lines.pop(0)
    for line in lines:
        row = parse_line(line)
        if row['State'] == 'ok':
            cloud = row['Cloud']
            conf = row['Conf']
            input = size_map[row['Inputs']]
            if not cloud in matrix:
                matrix[cloud] = dict()
            cell = matrix[cloud]
            if not conf in cell:
                cell[conf] = input
            else:
                cell[conf] = cell[conf] | input

    header_items = header.split(',')
    print(f"Instance,Provider,{header}")
    key_list = list(matrix.keys())
    key_list.sort()
    for key in key_list:
        p(key)
        p(',')
        p(instance_map[key])
        row = matrix[key]
        for h in header_items:
            p(',')
            if h in row:
                p(size_tranlate[row[h]])
        print()


if __name__ == '__main__':
    run()