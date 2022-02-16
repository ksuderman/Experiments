#!/usr/bin/env bash

REGION=${REGION:-us-east-1}
NAME=${NAME:-ea-cluster}

aws eks update-kubeconfig --region $REGION --name $NAME --profile cost-modeling
