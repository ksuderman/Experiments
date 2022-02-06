#!/usr/bin/env python3

import io
import os
import sys
from jinja2 import Template

def main(args):
    with open('helm/cloudcosts-template.yml', "r") as f:
        template = Template(f.read())

    data = {
        'name': name,
        'domain': 'usegvl',
        'tld': 'org',
        'title': args[0],
        'location': f'Amazon US-East-1'

    }

    print(template.render(**data))
    # yaml_data = template.render(**data)
    # data = yaml.safe_load(yaml_data)
    # print(data['extraFileMappings']['/galaxy/server/static/welcome.html']['content'])


if __name__ == "__main__":
    main(sys.argv[1:])
