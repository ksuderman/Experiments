#!/usr/bin/env bash

set -eu

#if [[ $# != 3 ]] ; then
#	echo "USAGE: $(basename $0) cloud namespace /path/to/benchmark.yml"
#	exit 1
#fi

#chart=$HOME/Workspaces/JHU/galaxy-helm-upstream/galaxy
chart=anvil/galaxykubeman

cloud=google
namespace=galaxy
benchmark=$1
experiment=${2:-experiment}
count=0
for config in default 4x8 8x16 16x32 ; do
	count=$((count + 1))
	abm $cloud helm update rules/$config.yml $namespace $chart
	abm $cloud bench run $benchmark "$count $cloud $config" $experiment
done

#abm $cloud helm update rules/4x8.yml $namespace $chart
##abm $cloud bench run $benchmark "1 $1 default" experiment

#abm $cloud helm update rules/8x16.yml $namespace $chart
#abm $cloud bench run $benchmark "1 $1 default" experiment

#abm $cloud helm update rules/4x8.yml $namespace $chart
#abm $cloud bench run $benchmark "1 $1 default" experiment
