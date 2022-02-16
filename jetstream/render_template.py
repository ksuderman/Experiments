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
    with open('files/template.yml.j2', "r") as f:
        template = Template(f.read())

    name = args[0]
    data = {
        'name': name,
        'domain': 'usegvl',
        'tld': 'org',
    }

    print(template.render(**data))
    # yaml_data = template.render(**data)
    # data = yaml.safe_load(yaml_data)
    # print(data['extraFileMappings']['/galaxy/server/static/welcome.html']['content'])


if __name__ == "__main__":
    main(sys.argv[1:])
