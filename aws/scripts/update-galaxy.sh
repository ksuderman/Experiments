#!/usr/bin/env bash
#
# Updates the container_mapper_rules.yml configuration file on the Galaxy instance

set -eu

if [[ $# == 0 ]] ; then
	echo "USAGE: $(basename $0) /path/to/container_mapper_rules.yml"
	echo
	exit 1
fi

NAMESPACE=${NAMESPACE:-gxy}
# TODO the default should not be to load from my local
CHART=$HOME/Workspaces/JHU/galaxy-helm-upstream/galaxy
#CHART=${CHART:-galaxy/galaxy}

KUBECONFIG=~/.kube/configs/eks helm upgrade galaxy -n $NAMESPACE $CHART \
 --reuse-values --set-file jobs.rules.container_mapper_rules\.yml.content=$1
 