#!/usr/bin/env bash

while [[ -z $(kubectl get nodes | grep master | grep ' Ready') ]] ; do
    echo "Waiting for Kubernetes to become available"
    sleep 10
done

echo "Kubernetes is ready."
