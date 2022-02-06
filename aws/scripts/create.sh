#!/usr/bin/env bash

# The end-to-end setup script used to provision infrastructure and install 
# Galaxy.  After this script is complete there should be a Galaxy instance
# running on a RKE cluster on AWS.

# ANSI color codes for the console.
reset="\033[0m"
bold="\033[1m"
ital="\033[3m" # does not work on OS X

# Function used to highlight text.
function hi() {
    echo -e "$bold$@$reset"
}

if [[ $# = 0 ]] ; then
    echo
    echo "$(hi SYNOPSIS)"
    echo "    Create clusters on AWS"
    echo
    echo "$(hi USAGE)"
    echo "    \$> $(basename $0) flavor [flavor...]"
    echo
    echo "$(hi OPTIONS)"
    echo "    $(hi flavor) the instance types that will be created"
    echo
    echp "$(hi EXAMPLES)"
    echo "   $(hi >) $(basename $0) m5 m5a m5n m6i"
    exit 1
fi

set -eu
prefix=$1
shift
saved=$@

S="\"$1\""
shift
while [[ $# > 0 ]] ; do
	S="$S,\"$1\""
	shift
done

echo "[$S]"
cd terraform
terraform apply --auto-approve -var instance_types="[$S]"
cd -

set -- $saved
#for flavor in $@ ; do
#	scripts/install.sh "$prefix$flavor" &
#done
scripts/install.sh $prefix $@





