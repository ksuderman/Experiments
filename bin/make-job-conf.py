#!/usr/bin/env python3

import sys
from ruamel.yaml import YAML

STARTER_YAML = '''jobs:
  rules:
    container_mapper_rules.yml:
      resources:
        resource_sets:
'''

resource_sets = ['small', 'medium', 'large', '2xlarge', 'mlarge']
limit_types = ['requests', 'limits']
resources = ['cpu', 'memory']

#        default_resource_set: small

def run(cpu: str, memory: str):
	yaml = YAML()
	#root = yaml.load(STARTER_YAML)
	#yaml.dump(root, sys.stdout)
	root = {}
	node = root
	for section in "jobs rules container_mapper_rules.yml resources resource_sets".split():
		node[section] = {}
		node = node[section]

	#data = root['jobs']['rules']['container_mapper_rules.yml']['resources']['resource_sets']
	#pprint(data)
	#yaml.dump(data, sys.stdout)
	for size in resource_sets:
		resource_set = {}
		node[size] = resource_set
		for limits in ['requests', 'limits']:
			resource_set[limits] = {
				'cpu': cpu,
				'memory': f"{memory}G"
			}
	root['jobs']['rules']['container_mapper_rules.yml']['resources']['default_resource_set'] = "small"
	yaml.dump(root, sys.stdout)


if __name__ == "__main__":
	if len(sys.argv) != 3:
		print(f"USAGE: {sys.argv[0]} CPU MEMORY")
	else:
		run(sys.argv[1], sys.argv[2])

