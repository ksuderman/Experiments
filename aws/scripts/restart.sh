#!/usr/bin/env bash

dir=$(dirname $0)
while [[ $# > 0 ]] ; do
	KUBECONFIG=~/.kube/configs/eks kubectl rollout restart deployment -n gxy $1
	shift
done

$dir/wait-for-galaxy.sh


