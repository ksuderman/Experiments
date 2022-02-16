#!/usr/bin/env bash

set -eu

configs="default 4x8 8x16 16x32"
chart=$HOME/Workspaces/JHU/galaxy-helm-upstream/galaxy


cloud=eks
namespace=gxy
benchmark=$1
experiment=${2:-experiment}
count=0

for config in $configs ; do
	count=$((count + 1))
	abm $cloud helm update resources/$config.yml $namespace $chart
	#echo "Using configuration $config"
	#KUBECONFIG=~/.kube/configs/eks helm upgrade galaxy -n $namespace $chart --reuse-values -f resources/$config.yml
	abm $cloud bench run $benchmark "$count $cloud $config" $experiment
done

#abm $cloud helm update rules/4x8.yml $namespace $chart
##abm $cloud bench run $benchmark "1 $1 default" experiment

#abm $cloud helm update rules/8x16.yml $namespace $chart
#abm $cloud bench run $benchmark "1 $1 default" experiment

#abm $cloud helm update rules/4x8.yml $namespace $chart
#abm $cloud bench run $benchmark "1 $1 default" experiment
