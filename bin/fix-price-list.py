#!/usr/bin/env python3

import sys
import csv
import yaml
from pprint import pprint

def run(filepath: str):
	with open(filepath, 'r') as f:
		data = csv.reader(f)
		print(','.join(next(data)))
		for row in data:
			print(f"{row[0]},{row[1]},{row[1]},{row[2]},{row[2]},{row[3]}")
	
	
if __name__ == '__main__':
	run(sys.argv[1])
