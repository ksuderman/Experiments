#!/usr/bin/env bash

filter=$1

echo -n "Waiting for $1:"
status=$(abm cl ls -l | grep $filter | rev | awk '{ print $1 }' | rev)
while [[ $status == 'LAUNCH:PROGRESSING' ]] ; do
	echo -n "."
	sleep 15
	status=$(abm cl ls -l | grep $filter | rev | awk '{ print $1 }' | rev)
done
echo $status