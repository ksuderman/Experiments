#!/usr/bin/env bash

set -eu

YEAR=$(($(date +%Y)-2000))
PROJECT=anvil-cost-modeling

# GKE information
export GKE_VERSION=${GKE_VERSION:-1.24}
export ZONE=${ZONE:-us-east1-b}

# Docker images to install
export ANVIL_IMAGE=${ANVIL_IMAGE:-quay.io/galaxyproject/galaxy-anvil}
export IMAGE=${IMAGE:-quay.io/galaxyproject/galaxy-min}
export TAG=${TAG:-22.05}

# Helm charts to use for installation
export CHART=${CHART:-galaxy/galaxy}
export CHART_VERSION=${CHART_VERSION:-5.4.0}
#export CHART=${CHART:-/Users/suderman/Workspaces/JHU/galaxy-helm/galaxy}
#export CHART_VERSION=${CHART_VERSION:-5.3.1-anvil.1}
#export GKM_CHART=${GKM_CHART:-anvil/galaxykubeman}
export GKM_CHART=${GKM_CHART:=/Users/suderman/Workspaces/JHU/galaxykubeman-helm/galaxykubeman}
export GKM_VERSION=${GKM_VERSION:-2.4.4}

export CVMFS_CHART=${CVMFS_CHART:=/Users/suderman/Workspaces/JHU/galaxy-cvmfs-csi-helm/galaxy-cvmfs-csi}

export PASSWORD=${PASSWORD:-galaxypassword}
export EMAIL=${EMAIL:-suderman@jhu.edu}

# VM Instance information
#export CLUSTER_NAME=${CLUSTER_NAME:-ks-cloudcosts}
export CLUSTER_NAME=${CLUSTER_NAME:-ks-terra-dev}
export BOOT_DISK=${BOOT_DISK:-100}
export DISK=${DISK:-505}
export MACHINE_FAMILY=${MACHINE_FAMILY:-e2}
export MACHINE_TYPE=${MACHINE_TYPE:-standard}
export MACHINE_CPU=${MACHINE_CPU:-32}
export MACHINE_DEFINITION=$MACHINE_FAMILY-$MACHINE_TYPE-$MACHINE_CPU
export NODE_POOL=${NODE_POOL:-default-pool}


export NAMESPACE=${NAMESPACE:-galaxy}
export NAME=${NAME:-galaxy}
#export CLUSTER_NAME=${CLUSTER_NAME:-ks-$MACHINE_DEFINITION-$(date +%Y%m%d)}
export KUBE=${KUBE:-$MACHINE_FAMILY}

GXY_TMP=/tmp/anvil-output.txt
VALUES=/tmp/anvil-values.yml

# ANSI color codes for the console.
reset="\033[0m"
bold="\033[1m"
ital="\033[3m" # does not work on OS X

# Function used to highlight text.
function hi() {
    echo -e "$bold$@$reset"
}

function help() {
    cat | less -RX << EOF 
    
$(hi USAGE)
   $0 [cluster|disks|pool|galaxy|anvil|cleanup]

$(hi SYNOPSIS)
    Provisions an Galaxy clusters on GKE.

$(hi COMMANDS)
    $(hi cluster)  
        provision a GKE cluster with a single node 
    $(hi disk)|$(hi disks)    
        provision two peristent disks for Postgres and NFS
    $(hi pool)
    	provision a GKE cluster with a node pool attached to the cluster
    $(hi galaxy)    
        deploy Galaxy to the cluster using the Galaxy Helm chart
    $(hi anvil)
    	deploy Galaxy to the cluster using the GalaxyKubeman Helm chart
    $(hi nfs)
    	install the Ganesha NFS provisioner
    $(hi values)
        generate the anvil-values.yml file from the template
    $(hi cleanup)  
        destroy the cluster, node pool, and disks
    $(hi -h)|$(hi --help)|$(hi help)
        print this help message and exit

Press $(hi Q) (twice) to exit help.
EOF
}

if [[ $# = 0 ]] ; then
    help
    exit
fi

function cleanup() {
    echo "Cleaning up"
    set +e
    gcloud container clusters delete -q $CLUSTER_NAME --zone $ZONE
    if [[ -e .state/disks ]] ; then
	    gcloud compute disks delete -q "$CLUSTER_NAME-postgres-pd" --zone $ZONE
	    gcloud compute disks delete -q "$CLUSTER_NAME-nfs-pd" --zone $ZONE
	    rm .state/disks
	fi
    if [[ -e ~/.kube/configs/$KUBE ]] ; then
      rm ~/.kube/configs/$KUBE
    fi
}

function cluster() {
	if [[ -e ~/.kube/config ]] ; then
		echo "WARNING: A kubeconfig file already exists. Aborting"
		exit 1
	fi
    echo "Creating the cluster"
    gcloud container clusters create "$CLUSTER_NAME" --cluster-version="$GKE_VERSION" --disk-size=$DISK --num-nodes=1 --machine-type=$MACHINE_DEFINITION --zone "$ZONE"
    #mv ~/.kube/config ~/.kube/configs/$KUBE
}

function node_pool() {
    echo "Creating the cluster"
    gcloud container clusters create "$CLUSTER_NAME" --cluster-version="$GKE_VERSION" --disk-size=$BOOT_DISK --num-nodes=1 --machine-type=n1-standard-1 --zone "$ZONE"
	echo "Creating the node pool"
	gcloud container node-pools create worker-pool --cluster "$CLUSTER_NAME"  --num-nodes 1 --machine-type=$MACHINE_DEFINITION --disk-size=$DISK --zone "$ZONE"
}

function disks() {
    echo "Provisioning persistent storage"
    gcloud compute disks create "$CLUSTER_NAME-postgres-pd" --size 10Gi --zone "$ZONE"
    gcloud compute disks create "$CLUSTER_NAME-nfs-pd" --size "$DISK""Gi" --zone "$ZONE"
    touch .state/disks
}

function generate_values() {
	if [[ -e anvil-values.yml ]] ; then
	    echo "A anvil-values.yml file already exists."
		return
	fi
	echo "Generating new values file"
	render_template.py --template anvil-values.tpl DISK=$DISK EMAIL=$EMAIL PASSWORD=$PASSWORD IMAGE=$ANVIL_IMAGE TAG=$TAG CLUSTER_NAME=$CLUSTER_NAME NODE_POOL=$NODE_POOL > anvil-values.yml
}

function anvil() {
  echo "Deploying $NAMESPACE:$NAME from $GKM_CHART"
  helm upgrade --install $NAME -n $NAMESPACE $GKM_CHART\
    --create-namespace\
    --wait\
    --timeout 2800s\
    --values anvil-values.yml\
    --set-file galaxy.configs.job_metrics_conf\.yml=job_metrics_conf.yml 

#    --version $GKM_VERSION\
  
  echo "http://$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | sed -e 's/"//g'):$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.spec.ports[0].port}')$(kubectl get ingress -n $NAMESPACE $NAME -o jsonpath='{.spec.rules[0].http.paths[0].path}')/"

}

function nfs() {
	helm install nfs-provisioner nfs-ganesha/nfs-server-provisioner \
	--set persistence.enabled=true\
	--set persistence.storageClass="standard" \
	--set persistence.size="400Gi" \
	--set storageClass.create=true \
	--set storageClass.defaultClass=false \
	--set storageClass.allowVolumeExpansion=true \
	--set storageClass.reclaimPolicy="Delete" \
	--namespace nfs-provisioner \
	--version 1.5.0\
	--create-namespace
}

function rclone() {
    helm upgrade --install rclone-csi wunderio/csi-rclone \
    --namespace csi-drivers \
    --set storageClass.name="rclone" \
    --set params.remote="google cloud storage" \
    --set params.remotePath="$NAME-gvl-data"
}

function ebs() {
	kubectl apply -f templates/gcp-ebs-storage-class.yml
}

function cvmfs() {
	echo "Installing CVMFS"
	helm install galaxy --namespace kube-system $CVMFS_CHART
}

function quota() {
	kubectl apply -f resource-quota.yaml -n $NAMESPACE
}

function rbac() {
	kubectl apply -f rbac-gkm.yaml
}

function galaxy() {
#    --version $CHART_VERSION \
  echo "Installing Galaxy from Helm chart $CHART "
  helm upgrade --install galaxy $CHART \
    --wait \
    --namespace $NAMESPACE\
    --reset-values\
	--create-namespace\
	--values gcp-values.yml\
    --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome.html
}

function gke() {
#    --version $CHART_VERSION \
  echo "Installing Galaxy from Helm chart $CHART "
  helm upgrade --install galaxy $CHART \
    --wait \
    --namespace $NAMESPACE\
    --reset-values\
	--create-namespace\
	--values gke-values.yml\
    --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome.html
}


function jetstream() {
#    --version $CHART_VERSION \
  echo "Installing Galaxy from Helm chart $CHART "
  helm upgrade --install galaxy $CHART \
    --version $CHART_VERSION \
    --wait \
    --namespace $NAMESPACE\
    --reset-values\
	--create-namespace\
	--values js2-values.yml\
    --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome-js2.html
}



function url() {
    echo "http://$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | sed -e 's/"//g'):$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.spec.ports[0].port}')$(kubectl get ingress -n $NAMESPACE $NAME -o jsonpath='{.spec.rules[0].http.paths[0].path}')/"
}

function show() {
    cat << __EOF__
export NAMESPACE=$NAMESPACE
export NAME=$NAME
export GKE_VERSION=$GKE_VERSION
export ZONE=$ZONE
export CHART=$CHART
export GKM_VERSION=$GKM_VERSION
export CLUSTER_NAME=$CLUSTER_NAME
export IMAGE=$IMAGE
export TAG=$TAG
export PASSWORD=$PASSWORD
export EMAIL=$EMAIL
export DISK=$DISK
export MACHINE_DEFINITION=$MACHINE_DEFINITION
export MACHINE_FAMILY=$MACHINE_FAMILY
export MACHINE_TYPE=$MACHINE_TYPE
export MACHINE_CPU=$MACHINE_CPU 
export KUBE=$KUBE
__EOF__
}

function clear() {
    cat << __EOF__
unset NAMESPACE
unset NAME
unset CLUSTER_NAME
unset IMAGE
unset TAG
unset PASSWORD
unset EMAIL
unset DISK
unset ZONE
unset GKM_VERSION
unset CHART
unset GKE_VERSION
unset MACHINE_FAMILY
unset MACHINE_TYPE
unset MACHINE_CPU
unset KUBE
__EOF__
}

# Shift through all the command line arguments and execute.
while [[ $# > 0 ]] ; do
    case $1 in
        cluster|disks|galaxy|anvil|cleanup|show|clear|nfs|cvmfs|quota|url|rbac|gke|rclone|ebs) 
            $1 
            ;;
        jetstream|js2)
        	jetstream
        	;;
        values)
            generate_values
            #exit
            ;;
        pool|node_pool)
        	node_pool
        	;;
        -h|--help|help)
            help
            exit
            ;;
        disk) 
            disks 
            ;;
        *)
            echo "$(hi ERROR): Invalid option $1"
            echo
            echo "Run $(hi $0 help) for usage instructions." 
            exit
            ;;
    esac
    shift
done

