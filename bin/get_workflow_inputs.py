#!/usr/bin/env python3

import sys
import json

def run(workflow_file: str):
    with open(workflow_file) as f:
        workflow = json.load(f)
    index = 0
    steps = workflow['steps']
    running = True
    while running:
        if str(index) in steps:
            step = steps[str(index)]
            if len(step['input_connections']) == 0:
                for input in step['inputs']:
                    print(input['name'])
        else:
            running=False
        index += 1


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("ERROR: provide exactly one filename")
        sys.exit(1)
    run(sys.argv[1])



