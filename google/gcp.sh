#!/usr/bin/env bash
set -eu

NAME=$(basename $0)

# Set the desired values for the following variables
INSTANCE_NAME="my-instance"
IMAGE_FAMILY="ubuntu-2202-focal-v20221208"
IMAGE_PROJECT="ubuntu-os-cloud"
IP_ADDRESS=""
MACHINE_TYPE="n2-standard-32"
REGION="us-east1"
ZONE="$REGION-b"
USERNAME="ubuntu"
SSH_PUBLIC_KEY="ks-cluster"
DISK_SIZE=500

# ANSI color codes for highlighting text in the console/terminal.
reset="\033[0m"
bold="\033[1m"

# Function used to highlight text.
function hi() {
    echo -e "$bold$@$reset"
}

function usage() {
	less -RX << EOF 

$(hi NAME)
    $NAME
	
$(hi DESCRIPTION) 
    Launch instances on GCP (Google Cloud Platform)
		
$(hi SYNOPSIS) 
    $NAME [--name name] [--type machine-type] [--address ip-address-name] [--disk size]
	
$(hi OPTIONS)
    $(hi -n)|$(hi --name)
        Name for the instance
    $(hi -t)|$(hi --type)
        Machine type ie $(hi n2-standard-32)
    $(hi -d)|$(hi --disk)
        Size of the instances boot disk (in GB)
    $(hi -a)|$(hi --address)
    	The name of the IP address to be assigned.
    $(hi -z)|$(hi --zone)
        Zone in which to launch the instance.
    $(hi -h)|$(hi --help)
        Print this help screen and exit.
         
$(hi EXAMPLES)
    $(hi \$\>) $NAME --type e2-highmem-4 --name my-instance --disk 768 --address ip-address-name
    
$(hi NOTES)
    If the $(hi --address) is specified the IP address must have already been allocated
    with $(hi gcloud compute addresses create ip-address-name).  Only IP address names
    are supported.
    
$(hi DEFAULTS)    
    $(hi machine type): $MACHINE_TYPE
    $(hi disk size)   : $DISK_SIZE
    $(hi username)    : $USERNAME
    $(hi zone)        : $ZONE
    
EOF
}

if [[ $# = 0 ]] ; then
	usage
	exit
fi

while [[ $# > 0 ]] ; do
	case $1 in
		-n|--name) 
			INSTANCE_NAME=$2
			shift
			;;
		-t|--type)
			MACHINE_TYPE=$2
			shift
			;;
		-a|--address)
			IP_ADDRESS="--address $2"
			shift
			;;
#		-k|--key)
#			SSH_PUBLIC_KEY=$2
#			shift
#			;;
		-d|--disk)
			DISK_SIZE=$2
			shift
			;;
		-z|--zone)
		    ZONE=$2
		    shift
		    ;;
		-h|--help)
			usage
			exit 
			;;
		*)
			echo "ERROR: Invalid parameter: $1"
			exit 1
	esac
	shift
done

# Create a new instance
#gcloud compute instances create $INSTANCE_NAME --zone $ZONE --image-family $IMAGE_FAMILY --image-project $IMAGE_PROJECT
#gcloud compute instances create $INSTANCE_NAME --zone $ZONE --image-family $IMAGE_FAMILY --image-project $IMAGE_PROJECT --machine-type $MACHINE_TYPE --boot-disk-size $DISK_SIZE #--metadata "ssh-keys=$USERNAME:$SSH_PUBLIC_KEY"
gcloud compute instances create $INSTANCE_NAME\
  --zone $ZONE\
  --machine-type $MACHINE_TYPE\
  --boot-disk-size $DISK_SIZE\
  --tags=http-server,https-server\
  --metadata-from-file=ssh-keys=ssh-keys.yml $IP_ADDRESS
   #--metadata "ssh-keys=$USERNAME:$SSH_PUBLIC_KEY"

# Create a new static external IP address
#gcloud compute addresses create $IP_ADDRESS_NAME --region $REGION

# Get the IP address
#IP_ADDRESS=$(gcloud compute addresses describe $IP_ADDRESS_NAME --region $REGION --format='value(address)')

# Assign the IP address to the instance
#gcloud compute instances add-access-config $INSTANCE_NAME --zone $ZONE --address $IP_ADDRESS

echo "Instance '$INSTANCE_NAME' created in zone '$ZONE' and region '$REGION'"
