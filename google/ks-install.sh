#!/usr/bin/env bash

NAMESPACE=${NAMESPACE:-gkmns}
ZONE=${ZONE:-us-east1-b}
PREFIX=${PREFIX:-ks}

BOOT=${BOOT:-100}
POSTGRES=${POSTGRES:-20}
NFS=${NFS:-512}
CHART=/Users/suderman/Workspaces/JHU/galaxykubeman-helm/galaxykubeman
#CHART="anvil/galaxykubeman --version=2.4.9"

function up() {
	gcloud container clusters create "$PREFIX-gkm" --cluster-version="1.24" --disk-size=$BOOT --num-nodes=1 --machine-type=e2-standard-16 --zone $ZONE

	#cd ~/galaxykubeman-helm/galaxykubeman/
	#helm dep up
	# Update values in ea-values.yaml 

	# Create the disks for use below
	gcloud compute disks create "$PREFIX-postgres-pd" --size ${POSTGRES}Gi --zone $ZONE
	gcloud compute disks create "$PREFIX-nfs-pd" --size ${NFS}Gi --zone $ZONE
}

function galaxy() {
	values=$PREFIX-values.yml
	if [[ ! -e $values ]] ; then
		echo "Rendering $values"
		render_template.py -t values.yml.j2 prefix=$PREFIX > $values
	else
		echo "Using existing values for $values"
	fi
	helm upgrade gkm --install $CHART\
	 --wait\
	 --create-namespace\
	 -n $NAMESPACE\
	 --values $values
	 #--set galaxy.image.repository=ksuderman/galaxy-anvil\
	 #--set galaxy.image.tag=22.05
}

function down() {
	gcloud container clusters delete $PREFIX-gkm -q --zone=$ZONE
	gcloud compute disks delete -q $PREFIX-postgres-pd --zone=$ZONE
	gcloud compute disks delete -q $PREFIX-nfs-pd --zone=$ZONE
}

while [[ $# > 0 ]] ; do
	case $1 in
		up|create) up ;;
		down|delete|cleanup) down ;;
		galaxy|install) galaxy ;;
		*) echo "Invalid command: $1" ; exit 1;;
	esac
	shift
done
