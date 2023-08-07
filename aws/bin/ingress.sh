#!/usr/bin/env bash

helm install ingress-nginx -n ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.kind="DaemonSet" \
  --set controller.hostNetwork=true \
  --set controller.daemonset.useHostPort=true
  
