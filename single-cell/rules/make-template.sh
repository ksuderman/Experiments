#!/usr/bin/env bash

cat << EOF
galaxy:
  jobs:
    rules:
      tpv_rules_local.yml:
        tools:  
EOF
for tool in $(cat tools.txt) ; do
    tool=${tool%/*}
    echo "          $tool/.*:"
    echo "            cores: {{ cores }}"
    echo "            mem: {{ mem }}"
done

