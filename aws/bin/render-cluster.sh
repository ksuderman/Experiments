#!/usr/bin/env bash

set -eu

#
# Generates the cluster.yml file that will be passed to `eks create cluster`
#

CPU=${1:-m6i}
SIZE=${2:-xlarge}
ID=$(cat /dev/urandom | LC_ALL=C tr -dc A-Za-z0-9 | head -c8)

#echo "ID: $ID"

OUTFILE=clusters/$CPU.$SIZE.yml

#python3 bin/render_template.py -t templates/cluster2.yml.j2 -f templates/cluster-values.yml cpuType=$CPU cpuSize=$SIZE id=$ID > $OUTFILE
python3 bin/render_template.py -t templates/cluster.yml.j2 -f templates/cluster-values.yml cpuType=$CPU cpuSize=$SIZE id=$ID > $OUTFILE
echo "Wrote $OUTFILE"
