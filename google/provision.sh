#!/usr/bin/env bash

set -eu

YEAR=$(($(date +%Y)-2000))
PROJECT=anvil-cost-modeling

export IMAGE=${IMAGE:-quay.io/galaxyproject/galaxy-anvil}
export TAG=${TAG:-22.05}
export GKE_VERSION=${GKE_VERSION:-1.24}
export ZONE=${ZONE:-us-east1-b}
export CHART=${CHART:-galaxy/galaxy}
#export CHART=${CHART:-anvil/galaxykubeman}
#export CHART=${CHART:=/Users/suderman/Workspaces/JHU/galaxy-helm/galaxy}
export GKM_CHART=${GKM_CHART:=/Users/suderman/Workspaces/JHU/galaxykubeman-helm/galaxykubeman}
#export CHART=${CHART:=ksuderman/galaxy}
export CHART_VERSION=${CHART_VERSION:-5.3.1}
export GKM_VERSION=${GKM_VERSION:-2.2.0}
export PASSWORD=${PASSWORD:-galaxypassword}
#export EMAIL=${EMAIL:-alex@fake.org}
export EMAIL=${EMAIL:=suderman@jhu.edu}

export BOOT_DISK=${BOOT_DISK:-525}
export DISK=${DISK:-505}
export MACHINE_FAMILY=${MACHINE_FAMILY:-e2}
export MACHINE_TYPE=${MACHINE_TYPE:-standard}
export MACHINE_CPU=${MACHINE_CPU:-32}
export MACHINE_DEFINITION=$MACHINE_FAMILY-$MACHINE_TYPE-$MACHINE_CPU
export NAMESPACE=${NAMESPACE:-galaxy}
export NAME=${NAME:-galaxy}
#export CLUSTER_NAME=${CLUSTER_NAME:-ks-$MACHINE_DEFINITION-$(date +%Y%m%d)}
#export CLUSTER_NAME=ks-cloudcosts
export CLUSTER_NAME=${CLUSTER_NAME:-ks-cloudcosts}
export KUBE=${KUBE:-$MACHINE_FAMILY}
export NODE_POOL=${NODE_POOL:-worker-pool}

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
    cat | less -R << EOF 
    
$(hi USAGE)
   $0 [cluster|disks|galaxy|cleanup]

$(hi SYNOPSIS)
    Provisions an Galaxy clusters on GCP using the Galaxy Kubeman Helm chart.

$(hi COMMANDS)
    $(hi cluster)  
        provision a GKE cluster on GCP
    $(hi disk)|$(hi disks)    
        provision two peristent disks for Postgres and NFS
    $(hi galaxy)    
        deploy Galaxy to the cluster using the Kubeman helm chart
    $(hi cleanup)  
        destroy the cluster and disks
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
    gcloud compute disks delete -q "$CLUSTER_NAME-postgres-pd" --zone $ZONE
    gcloud compute disks delete -q "$CLUSTER_NAME-nfs-pd" --zone $ZONE
    if [[ -e ~/.kube/configs/$KUBE ]] ; then
      rm ~/.kube/configs/$KUBE
    fi
}

function cluster() {
	#if [[ -e ~/.kube/config ]] ; then
	#	echo "WARNING: A kubeconfig file already exists. Aborting"
	#	exit 1
	#fi
    echo "Creating the cluster"
    gcloud container clusters create "$CLUSTER_NAME" --cluster-version="$GKE_VERSION" --disk-size=$BOOT_DISK --num-nodes=1 --machine-type=n1-standard-1 --zone "$ZONE"
    #mv ~/.kube/config ~/.kube/configs/$KUBE
}

function node_pool() {
	echo "Creating the node pool"
	gcloud container node-pools create worker-pool --cluster "$CLUSTER_NAME"  --num-nodes 1 --machine-type=$MACHINE_DEFINITION --disk-size=$DISK --zone "$ZONE"
}

function disks() {
    echo "Provisioning persistent storage"
    gcloud compute disks create "$CLUSTER_NAME-postgres-pd" --size 10Gi --zone "$ZONE"
    gcloud compute disks create "$CLUSTER_NAME-nfs-pd" --size "$DISK""Gi" --zone "$ZONE"
}

function invoke() {
  if [[ -e ~/.kube/configs/$KUBE ]] ; then
	  KUBECONFIG=~/.kube/configs/$KUBE $@
	else
	  $@
	fi
}

function generate_values() {
	if [[ -e anvil-values.yml ]] ; then
	  echo "A anvil-values.yml file already exists."
		return
	fi
	echo "Generating new values file"
	../bin/render_template.py --template anvil-values.tpl DISK=$DISK EMAIL=$EMAIL PASSWORD=$PASSWORD IMAGE=$IMAGE TAG=$TAG CLUSTER_NAME=$CLUSTER_NAME NODE_POOL=$NODE_POOL> anvil-values.yml
}

function anvil() {
    echo "Deploying Galaxy with the Galaxy Kubeman helm chart"
    generate_values
    helm upgrade --install $NAME -n $NAMESPACE $CHART\
 --create-namespace\
 --wait\
 --timeout 2800s\
 --version $GKM_VERSION\
 --set galaxy.image.repository="$IMAGE"\
 --set galaxy.image.tag="$TAG"\
 --set nfs.storageClass.name="nfs-$CLUSTER_NAME"\
 --set cvmfs.repositories.cvmfs-gxy-data-$CLUSTER_NAME="data.galaxyproject.org"\
 --set cvmfs.cache.alienCache.storageClass="nfs-$CLUSTER_NAME"\
 --set galaxy.persistence.storageClass="nfs-$CLUSTER_NAME"\
 --set galaxy.cvmfs.galaxyPersistentVolumeClaims.data.storageClassName=cvmfs-gxy-data-$CLUSTER_NAME\
 --set galaxy.service.type=LoadBalancer\
 --set galaxy.service.port=8000\
 --set rbac.enabled=false\
 --set galaxy.configs.file_sources_conf\.yml='""'\
 --set galaxy.terra.launch.namespace="galaxy-anvil-edge"\
 --set cvmfs.cache.preload.enabled=false\
 --set galaxy.configs.galaxy\.yml.galaxy.master_api_key=$PASSWORD\
 --set galaxy.configs.galaxy\.yml.galaxy.single_user="$EMAIL"\
 --set galaxy.configs.galaxy\.yml.galaxy.admin_users="$EMAIL"\
 --set galaxy.configs.galaxy\.yml.galaxy.job_metrics_config_file=job_metrics_conf.yml\
 --set-file galaxy.configs.job_metrics_conf\.yml=job_metrics_conf.yml \
 --set persistence.nfs.name="$CLUSTER_NAME-nfs-disk"\
 --set persistence.nfs.persistentVolume.extraSpec.gcePersistentDisk.pdName="$CLUSTER_NAME-nfs-pd"\
 --set persistence.nfs.size=200Gi\
 --set persistence.postgres.name="$CLUSTER_NAME-postgres-disk"\
 --set persistence.postgres.persistentVolume.extraSpec.gcePersistentDisk.pdName="$CLUSTER_NAME-postgres-pd"\
 --set persistence.postgres.size="10Gi"\
 --set nfs.persistence.existingClaim="$CLUSTER_NAME-nfs-disk-pvc"\
 --set nfs.persistence.size=200Gi\
 --set galaxy.postgresql.persistence.existingClaim="$CLUSTER_NAME-postgres-disk-pvc"\
 --set galaxy.persistence.size=200Gi\
 --set galaxy.postgresql.galaxyDatabasePassword=$PASSWORD\
 --set galaxy.webHandlers.startupDelay=10\
 --set galaxy.jobHandlers.startupDelay=5\
 --set galaxy.workflowHandlers.startupDelay=0 \
 --set nfs.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool" \
 --set galaxy.postgresql.master.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"\
 --set galaxy.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"\
 --set cvmfs.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"
 --set galaxy.terra.launch.workspace='"De novo transcriptome reconstruction with RNA-Seq"'\
 --set galaxy.configs.job_conf\.yml.runners.k8s.k8s_node_selector='"cloud.google.com/gke-nodepool: default-pool"'

    echo "http://$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | sed -e 's/"//g'):$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.spec.ports[0].port}')$(kubectl get ingress -n $NAMESPACE $NAME -o jsonpath='{.spec.rules[0].http.paths[0].path}')/"
}

function anvil2() {
  echo "Deploying $NAMESPACE:$NAME from $GKM_CHART"
  echo helm upgrade --install $NAME -n $NAMESPACE $GKM_CHART\
    --create-namespace\
    --wait\
    --timeout 2800s\
    --version $GKM_VERSION\
    --values anvil-values.yml\
    --set-file galaxy.configs.job_metrics_conf\.yml=job_metrics_conf.yml 
  
  echo "http://$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | sed -e 's/"//g'):$(kubectl get svc -n $NAMESPACE $NAME-nginx -o jsonpath='{.spec.ports[0].port}')$(kubectl get ingress -n $NAMESPACE $NAME -o jsonpath='{.spec.rules[0].http.paths[0].path}')/"

}

function nfs() {
	invoke helm install nfs-provisioner nfs-ganesha/nfs-server-provisioner \
	--set persistence.enabled=true\
	--set persistence.storageClass="standard" \
	--set persistence.size="500Gi" \
	--set storageClass.create=true \
	--set storageClass.defaultClass=false \
	--set storageClass.allowVolumeExpansion=true \
	--set storageClass.reclaimPolicy="Delete" \
	--namespace nfs-provisioner \
	--create-namespace
}

function _cvmfs() {
  invoke helm install cvmfs-csi galaxy/galaxy-cvmfs-csi \
  --set cache.alienCache.enabled=true \
  --set cache.alienCache.storageClass="nfs" \
  --set cache.localCache.enabled=false \
  --namespace cvmfs-csi \
  --create-namespace
}

function galaxy() {
  echo "Installing Galaxy from Helm chart $CHART "
  helm upgrade --install galaxy $CHART \
  --version $CHART_VERSION \
  --wait \
	--namespace $NAMESPACE\
	--reset-values\
	--create-namespace\
	--values gcp-values.yml\
  --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome.html
  #	--version $CHART_VERSION\
}

function s3fs() {
  echo "Installing Galaxy from Helm chart ksuderman/galaxy v4.11.0-s3fs"
  helm upgrade --install galaxy ksuderman/galaxy \
	--version 4.11.0-s3fs \
	--namespace $NAMESPACE\
	--create-namespace\
	-f fs-values.yml\
	--set cvmfs.enabled=false --set cvmfs.deploy=false \
  --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome-s3fs.html
  #	--version $CHART_VERSION\
}

function cvmfs() {
  echo "Installing Galaxy from Helm chart ksuderman/galaxy v4.11.0-cvmfs"
  helm upgrade --install galaxy galaxy/galaxy \
	--namespace $NAMESPACE\
	--create-namespace\
	-f fs-values.yml\
	--set cvmfs.enabled=true \
	--set cvmfs.deploy=true \
  --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome-cvmfs.html
  #	--version $CHART_VERSION\
}


function _galaxy() {
    invoke helm upgrade --install galaxy galaxy/galaxy \
    --namespace $NAMESPACE \
    --create-namespace \
    --set persistence.accessMode="ReadWriteMany" \
    --set persistence.storageClass="nfs" \
    --set persistence.size="50Gi" \
    --set ingress.enabled=false \
    --set postgresql.persistence.storageClass="standard" \
    --set postgresql.galaxyDatabasePassword=galaxydbpassword \
    --set influxdb.enabled=false \
    --set service.type=LoadBalancer \
    --set service.port=80 \
    --set cvmfs.enabled=true \
    --set cvmfs.deploy=false \
    --set image.tag=$TAG \
    --set configs."job_conf\.yml".runners.k8s.k8s_unschedulable_walltime_limit="604800" \
    --set configs."job_conf\.yml".runners.k8s.k8s_walltime_limit="604800" \
    --set configs."galaxy\.yml".galaxy.admin_users="suderman@jhu.edu\,bcarr15@jhu.edu\,vwen2@jhu.edu\,enis.afgan@gmail.com\,admin@galaxyproject.org" \
    --set-file extraFileMappings."/galaxy/server/static/welcome\.html".content=welcome.html 
    
    # --create-namespace
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


# Save command line arguments so we can shift through them twice; once to check
# that all commands are valid, and a second time to run the commands.
saved=$@

while [[ $# > 0 ]] ; do
    case $1 in
        cluster|disks|galaxy|anvil|anvil2|cleanup|show|clear|nfs|cvmfs|s3fs|url) 
            $1 
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

