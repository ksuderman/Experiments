import json
import sys
import os.path

import boto3
from pprint import pprint
import json
from urllib.request import urlopen

#pricing_client = None


def price_lookup(args: list):
    if len(args) == 0:
        print("ERROR: No price list provided")
        return

    filepath = args[0]
    if not os.path.exists(filepath):
        print(f"ERROR: Unable to fine {filepath}")
        return

    with open(filepath) as f:
        data = json.load(f)

    print(f"Loaded {filepath}")
    for region_data in data['config']['regions']:
        region = region_data['region']
        for instance_data in region_data['instanceTypes']:
            for size_data in instance_data['sizes']:
                size = size_data['size']
                cpu = size_data['vCPU']
                mem = size_data['memoryGiB']
                price = size_data['valueColumns'][0]['prices']['USD']
                print(f"{region},{size},{cpu},{mem},{price}")



def get_products(region, instanceType):
    pricing_client = boto3.client('pricing', region_name='us-east-1')
    paginator = pricing_client.get_paginator('get_products')

    response_iterator = paginator.paginate(
        ServiceCode="AmazonEC2",
        Filters=[
            {
                'Type': 'TERM_MATCH',
                'Field': 'location',
                'Value': region
            },
            {
                'Type': 'TERM_MATCH',
                'Field': 'instanceType',
                'Value': instanceType
            }
        ],
        PaginationConfig={
            'PageSize': 100
        }
    )

    products = []
    for response in response_iterator:
        for priceItem in response["PriceList"]:
            priceItemJson = json.loads(priceItem)
            products.append(priceItemJson)

    print(json.dumps(products, indent=4))

if __name__ == '__main__':
    get_products('US East (N. Virginia)', 'c5a.2xlarge')
    #price_lookup(sys.argv[1:])

