#!/usr/bin/env bash
set -eu

# To use this script you will need to get a (free) API token from https://vantage.sh
# The secret file should look like:
# export TOKEN=<your API token>
source ~/.secret/vantage.sh

# The instance types we want to price
#="m5 m5a m5n m6i m6a r6i c6i c6a"
TYPES="m6i m6a r6i c6i"
# The instance sizes we want to price
SIZES="xlarge 2xlarge 4xlarge 8xlarge"

CONFIGS=""
function get_price() {
	url=https://api.vantage.sh/v1/products/aws-ec2-$1_$2/prices/aws-ec2-$1_$2-us_east_1-on_demand-linux
    cost=$(curl --silent --header "Authorization: Bearer $TOKEN" $url | jq -r .amount)
    echo $cost
}

for type in $TYPES ; do
	echo -n $type
	for size in $SIZES ; do
		cost=$(get_price $type $size)
		echo -n ",$cost,$cost"
	done
	echo
done