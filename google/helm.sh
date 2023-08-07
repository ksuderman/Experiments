#!/usr/bin/env bash

CHART=${CHART:-../../galaxy-helm/galaxy}
COMMON=${COMMON:-../resource-prediction/values/common.yml}
VALUES=${VALUES:-../resource-prediction/values/gcp.yml}
HTML=${1:-welcome.html}

if [[ ! -e $CHART ]] ; then
	echo "Chart not found: $CHART"
	exit 1
fi 
if [[ ! -e $VALUES ]] ; then
	echo "Values not found: $VALUES"
	exit 1
fi

echo "Installing Galaxy from $CHART"
echo "Using common values      : $COMMON"
echo "Using GCP specific values: $VALUES"
helm upgrade --install galaxy -n galaxy $CHART --create-namespace --values $COMMON --values $VALUES --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=$HTML
