#!/usr/bin/env bash
set -eu

#INSTANCES=${INSTANCES:-n1 n2 c2 e2}
INSTANCES=${@:-n1}
PROFILE=~/.abm/profile.yml

USER=suderman
EMAIL=suderman@jhu.edu
PASSWORD=galaxypassword

function rewrite() {
    cat $PROFILE | sed "s|$1|$2|" > /tmp/profile.yml
    rm $PROFILE
    mv /tmp/profile.yml $PROFILE
}

for i in $INSTANCES ; do
    echo "Provisioning $i"
    (source settings/$i && ./provision.sh cluster nfs galaxy)
    bin/wait-for-galaxy.sh
    ip=$(kubectl get svc -n galaxy galaxy-nginx -o json | jq .status.loadBalancer.ingress[0].ip | sed 's/\"//g')
    mv ~/.kube/config ~/.kube/configs/$i
    abm config create $i ~/.kube/configs/$i
    abm config url $i http://$ip
    #curl $url
  	key=$(abm $i user create $USER $EMAIL $PASSWORD | cut -d\  -f7)
  	#key=$(abm $type user key $EMAIL)
	  abm config key $i $key
  	abm $i workflow upload ../assets/workflows/dna-cloud-costs.ga
	  count=5
    while [[ $count > 0 ]] ; do
      count=$((count - 1))
      abm $i history import dna
      state=$(abm $i job ls | head -n 1 | awk '{print $2}')
      if [[ $state == ok ]] ; then
        echo "Upload successful"
      else
        echo "Upload failed.  Retrying"
      fi
    done
    abm $i job ls | head -n 1


    #key=$(abm $i user key suderman@jhu.edu)
    #abm config key $i $key
    #echo "Bootstrapping $i"
    #abm $i workflow upload workflows/dna-cloud-costs.ga
    #abm $i history import dna
    #abm $i history import rna
done

#abm experiment run experiment.yml

# TODO Cleanup instances