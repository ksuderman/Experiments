#!/usr/bin/env bash

html=${1:-welcome.html}

helm upgrade galaxy -n galaxy galaxy/galaxy --reuse-values \
  --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=$html
