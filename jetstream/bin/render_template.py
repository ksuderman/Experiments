#!/usr/bin/env python3

import io
import os
import sys
from jinja2 import Template

numbers = ['Zero', 'One', 'Two','Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten']

locations = {
    'TACC': ' the Texas Advanced Computing Center',
    'IU': 'Indiana University'
}

def test(args):
    print(numbers[int(args[0])])


def main(args):
    with open('helm/cloudcosts-template.yml', "r") as f:
        template = Template(f.read())

    if args[0] == 'texas':
        cloud = 'TACC'
    else:
        cloud = args[0].upper()
    name = f"{args[0]}{args[1]}"
    try:
        number = numbers[int(args[1])]
    except:
        number = args[1]
    data = {
        'name': name,
        'domain': 'usegvl',
        'tld': 'org',
        'title': f'Jetstream/{ cloud } - Bench { number }',
        'location': f'Jetstream at { locations[cloud] }'

    }

    print(template.render(**data))
    # yaml_data = template.render(**data)
    # data = yaml.safe_load(yaml_data)
    # print(data['extraFileMappings']['/galaxy/server/static/welcome.html']['content'])


if __name__ == "__main__":
    main(sys.argv[1:])
