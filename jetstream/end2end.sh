#!/usr/bin/env bash

if [[ -z $1 ]] ; then
    echo "USAGE: $0 <name> <number>"
    echo "     : $0 tacc 1"
    exit 1
fi

set -eu

CLOUD=$1
#echo "CLOUD is $CLOUD"
shift

while [[ $# > 0 ]] ; do
    ID=$1
    #echo "ID is $ID"
    shift
    
    NAME="$CLOUD$ID"
    echo "Instance name is $NAME"

    CHART="galaxy/galaxy"
    INVENTORY=~/.inventories/$NAME.ini

    if [[ ! -e $INVENTORY ]] ; then
        echo "ERROR: File not found: $INVENTORY"
        exit 1
    fi

    if [[ -L ~/.kube/config ]] ; then
        echo "Removing the currently linked kubeconfig"
        rm ~/.kube/config
    fi

    cd ansible

    # Update and reboot if needed.
    ansible-playbook -i $INVENTORY update.yml

    # Install RKE2
    if [[ -d rke/outputs ]] ; then
        rm rke/outputs/*.config
    fi
    ansible-playbook -i $INVENTORY rke/main.yml

    kubeconfig=$(ls rke/outputs/*.config)
    if [[ ! -e $kubeconfig ]] ; then
        echo "ERROR: Unable to find the kubeconfig in rke/outputs"
        echo $kubeconfig
        exit 1
    fi
    if [[ -e ~/.kube/configs/$NAME ]] ; then
        echo "Removing the existing kubeconfig ~/.kube/configs/$NAME"
        rm ~/.kube/configs/$NAME
    fi

    cp $kubeconfig ~/.kube/configs/$NAME
    ln -s ~/.kube/configs/$NAME ~/.kube/config
    chmod 0600 ~/.kube/configs/$NAME
    chmod 0600 ~/.kube/config

    while [[ -z $(kubectl get nodes | grep master | grep ' Ready') ]] ; do
        echo "Waiting for Kubernetes to be ready"
        sleep 30
    done
    echo "Kubernetes is ready"
    #exit

    ansible-playbook -i $INVENTORY setup.yml
    ansible-playbook -i $INVENTORY cert-manager.yml

    cd -

    VALUES=/tmp/$NAME.yml # ../helm-configs/cloudcosts-$1.yml
    echo "Generating $VALUES"
    python3 render_template.py $NAME > $VALUES
    COMMON=files/values.yml

    #cd ~/Workspaces/JHU/galaxy-helm
    #WELCOME=./welcome-2109-$1.html
    helm upgrade galaxy -n galaxy $CHART --install --create-namespace --reuse-values -f $COMMON -f $VALUES 

    echo "Galaxy should be available in a few minutes"
done