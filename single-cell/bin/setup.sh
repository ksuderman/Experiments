#!/usr/bin/env bash

cloud=test

# ANSI color codes for the console.
reset="\033[0m"
bold="\033[1m"
ital="\033[3m" # does not work on OS X

# Function used to highlight text.
function hi() {
    echo -e "$bold$@$reset"
}

NAME=$(basename $(realpath $0))

function help() {
    #cat | less -RX << EOF 
    less -RX << EOF 
    
$(hi NAME)
    $NAME
	 
$(hi DESCRIPTION)
    Configure a new AnVIL cluster

$(hi SYNOPSIS)
    $NAME [COMMAND] [OPTIONS]

$(hi COMMANDS)
    $(hi -u|--user|user)   		  Create a new user.
    $(hi -h|--history|history)    Import data as a single history.
    $(hi -d|--datasets|datasets)  Import data as individual datasets.
    $(hi -w|--workflow|workflow)  Import the workflow.
	$(hi -H|--help|help)          Print this help message and exit.
	
$(hi OPTIONS)
    $(hi -c)|$(hi --cloud)        The cloud instance to be initialized. Defaults to $(hi test).

$(hi EXAMPLES)
    \$> $NAME --cloud galaxy user history workflow
    
EOF
}

if [[ $# == 0 ]] ; then
	help
	exit
fi

create_user="false"
import_workflow="false"
import_history="false"
import_datasets="false"
while [[ $# > 0 ]] ; do
    case $1 in
        -c|--cloud)
            cloud=$2
            shift
            ;;
        -u|--user|user)
            create_user="true"
            ;;
        -h|--history|history)
            import_history="true"
            ;;
        -d|--datasets|datasets)
            import_datasets="true"
            ;;
        -w|--workflow|workflow)
            import_workflow="true"
            ;;
        -H|--help|help)
        	help
        	exit 1
        	;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
    shift
done

echo "Setting up $cloud"
if [[ $create_user = "true" ]] ; then
    echo "Creating user"
    key=$(abm $cloud user create suderman suderman@jhu.edu galaxypassword | jq -r .key)
    echo "Setting user key $key"
    abm config key $cloud $key
fi
if [[ $import_workflow = "true" ]] ; then
    echo "Uploading workflow"
    abm $cloud workflow import single-cell-matrix
fi
if [[ $import_history = "true" ]] ; then
    echo "Importing history"
    abm $cloud history import single-cell-matrix
fi
if [[ $import_datasets = "true" ]] ; then
    echo "Importing datasets"
    abm $cloud history create "Single Cell Input"
    for set in design gtf cdna read1 read2 ; do
        abm $cloud dataset import single-cell-$set --name $set --history "Single Cell Input"
    done
fi
