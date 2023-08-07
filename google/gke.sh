#!/usr/bin/env bash

GKE_VERSION=1.24
GKM_VERSION=2.4.4
GKE_ZONE=us-east1-b
COMMON_PASSWORD=galaxypassword

prefix=${1:-ks-dev}

gcloud container clusters create "$prefix" --cluster-version="$GKE_VERSION" --disk-size=100 --num-nodes=1 --machine-type=e2-custom-20-81920 --zone "$GKE_ZONE"
gcloud compute disks create "$prefix-1-postgres-pd" --size 10Gi --zone "$GKE_ZONE"
gcloud compute disks create "$prefix-1-nfs-pd" --size 250Gi --zone "$GKE_ZONE"
#gcloud container clusters get-credentials "$prefix" --zone "$GKE_ZONE"

helm install --create-namespace -n $prefix-1 $prefix-1 anvil/galaxykubeman\
              --wait\
              --wait-for-jobs\
              --timeout 720s\
              --version $GKM_VERSION\
              --set galaxy.image.version=22.05\
              --set galaxy.service.type=LoadBalancer\
              --set galaxy.configs."galaxy\.yml".galaxy.admin_users="tests@fake.org"\
              --set galaxy.configs."galaxy\.yml".galaxy.master_api_key=$COMMON_PASSWORD\
              --set galaxy.configs."galaxy\.yml".galaxy.single_user="tests@fake.org"\
              --set 'galaxy.configs.job_conf\.yml.execution.environments.tpv_dispatcher.tpv_config_files={https://raw.githubusercontent.com/galaxyproject/tpv-shared-database/main/tools.yml,lib/galaxy/jobs/rules/tpv_rules_local.yml,https://gist.githubusercontent.com/afgane/68d1dbbe0af2468ba347dc74b6d3f7fa/raw/20edda50161bdcb74ff38935e7f76d79bfdaf303/tvp_rules_tests.yml}'\
              --set galaxy.persistence.storageClass="nfs-$prefix-1"\
              --set galaxy.postgresql.galaxyDatabasePassword=$COMMON_PASSWORD\
              --set galaxy.postgresql.persistence.existingClaim="$prefix-1-postgres-disk-pvc"\
              --set galaxy.rabbitmq.persistence.storageClassName="nfs-$prefix-1"\
              --set galaxy.ingress.ingressClassName=""\
              --set galaxy.tusd.ingress.ingressClassName=""\
              --set cvmfs.cvmfscsi.cache.alien.pvc.storageClass="nfs-$prefix-1"\
              --set nfs.persistence.existingClaim="$prefix-1-nfs-disk-pvc"\
              --set nfs.storageClass.name="nfs-$prefix-1"\
              --set persistence.nfs.name="$prefix-1-nfs-disk"\
              --set persistence.nfs.persistentVolume.extraSpec.gcePersistentDisk.pdName="$prefix-1-nfs-pd"\
              --set persistence.postgres.name="$prefix-1-postgres-disk"\
              --set persistence.postgres.persistentVolume.extraSpec.gcePersistentDisk.pdName="$prefix-1-postgres-pd"

exit

#              --set galaxy.configs."job_conf\.yml".runners.k8s.k8s_node_selector="cloud.google.com/gke-nodepool: default-pool"\
#              --set galaxy.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"\
#              --set galaxy.postgresql.master.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"\
#              --set galaxy.rabbitmq.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"\
#              --set nfs.nodeSelector."cloud\.google\.com\/gke-nodepool"="default-pool"\

