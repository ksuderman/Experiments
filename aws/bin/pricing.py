import json
import boto3
from pprint import pprint
import json
from urllib.request import urlopen

#pricing_client = None


def price_lookup():
    pass

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
    #get_products('US East (N. Virginia)', 'c5a.2xlarge')
    price_lookup()

