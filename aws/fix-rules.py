import sys
from ruamel.yaml import YAML

yaml = YAML()

with open(sys.argv[1], 'r') as f:
	data = yaml.load(f)
	
conf = {
	'jobs': { 
	  'rules': {
	    'container_mapper_rules.yml': data
	  }
	  
	}	  
}

yaml.dump(conf, sys.out)