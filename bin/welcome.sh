#!/usr/bin/env bash

CHART=${CHART:-../../galaxy-helm/galaxy}
HTML=${1:-welcome.html}

if [[ ! -e $CHART ]] ; then
	echo "Chart not found: $CHART"
	exit 1
fi 

echo "Updating Galaxy welcome page"
helm upgrade galaxy -n galaxy $CHART --reuse-values --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=$HTML
