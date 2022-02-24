#!/usr/bin/env bash

CPU=${1:-m5a}
SIZE=${2:-xlarge}

OUTFILE=clusters/$CPU.$SIZE.yml

python bin/render_template.py -t templates/cluster2.yml.j2 -f templates/cluster-values.yml cpuType=$CPU cpuSize=$SIZE > $OUTFILE
echo "Wrote $OUTFILE"
