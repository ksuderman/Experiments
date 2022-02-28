#!/usr/bin/env python3

# A simple script to generate the resource_sets sections of the container_mapper_rules.yml
# file that will be used to `helm upgrade` clusters.
#
# USAGE
#
# python3 make-job-conf.py CPU_LIMIT MEMORY_LIMIT
#
# EXAMPLE
#
# python3 make-job-conf.py 4 16

import sys
from ruamel.yaml import YAML

resource_sets = ['small', 'medium', 'large', '2xlarge', 'mlarge']

def run(cpu: int, memory: str):
	yaml = YAML()
	root = {}
	node = root
	# Build the root of the tree up to the resource_sets entry
	for section in "jobs rules container_mapper_rules.yml resources resource_sets".split():
		node[section] = {}
		node = node[section]

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

