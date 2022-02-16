#!/usr/bin/env python3

import sys
from ruamel.yaml import YAML

yaml = YAML()

def quote(s: str):
	if not '.' in s:
		return s
	s = s.replace('.', '\\.')
	return f'"{s}"'
	
	
def make_key(head: str, tail):
	if type(tail) is str or type(tail) is int:
		print(f' --set {head}={tail}\\')
	#if not type(tail) is dict:
	else:
		for k,v in tail.items():
			make_key(f'{head}.{quote(k)}', v)


with open(sys.argv[1], 'r') as f:
	data = yaml.load(f)

print("KUBECONFIG=/Users/suderman/.kube/configs/eks")	
print("helm upgrade galaxy -n gxy /Users/suderman/Workspaces/JHU/galaxy-helm-upstream/galaxy\\")
for k,v in data.items():
	make_key(k, v)
print("--reuse-values")
