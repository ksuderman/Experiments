aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) --profile cost-modeling

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add stable https://charts.helm.sh/stable
helm repo update

kubectl create namespace ingress-nginx

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --version 3.34.0 \
    --namespace ingress-nginx \
    --set controller.kind="DaemonSet" \
    --set controller.hostNetwork=true \
    --set controller.daemonset.useHostPort=true

# Manually add AmazonEKSClusterPolicy to the IAM role assoc. with the worker nodes (or figure out how to have it done automatically)

kubectl create namespace csi-drivers

kubectl apply -f ebs_storage_class.yml

helm upgrade --install aws-ebs-csi-driver https://github.com/kubernetes-sigs/aws-ebs-csi-driver/releases/download/v0.6.0/helm-chart.tgz \
    --namespace csi-drivers \
    --set enableVolumeScheduling=true \
    --set enableVolumeResizing=true \
    --set enableVolumeSnapshot=true

helm upgrade --install nfs-provisioner stable/nfs-server-provisioner \
    --namespace csi-drivers \
    --set persistence.enabled=true \
    --set persistence.storageClass="ebs" \
    --set persistence.size=501Gi \
    --set storageClass.create=true \
    --set storageClass.reclaimPolicy="Delete" \
    --set storageClass.allowVolumeExpansion=true

kubectl create ns gxy

helm install -n gxy galaxy /Users/ea/projects/galaxy-helm/galaxy/ -f gxy_values.yml

# Galaxy will be accessible at the URL for the nginx ingress service available from
kubectl get services -n ingress-nginx


# To delete a cluster, first manually delete all servcies (which will delete an ELB that TF doesn't know about and hence cannot delete it)
kubectl delete --all services --all-namespaces

kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
