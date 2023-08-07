galaxy:
  image: 
    repository: {{ IMAGE }}
    tag: {{ TAG }}
  nodeSelector:
    cloud.google.com/gke-nodepool: {{ NODE_POOL }}
  ingress:
    ingressClassName: ""
  tusd:
    ingress:
      ingressClassName: ""
  terra:
    launch:
      namespace: galaxy-anvil-edge
      workspace: De novo transcriptome reconstruction with RNA-Seq
  configs:
    job_conf.yml:
      runners:
        k8s:
          k8s_node_selector: "cloud.google.com/gke-nodepool: {{ NODE_POOL }}"
    galaxy.yml:
      galaxy:
        master_api_key: {{ PASSWORD }}
        single_user: {{ EMAIL }}
        admin_users: {{ EMAIL }}
        job_metrics_config_file: job_metrics_conf.yml
  persistence:
    storageClass: nfs-{{ CLUSTER_NAME }}
    size: "200Gi"
  service:
    type: LoadBalancer
    port: 8000   
  postgres:
    galaxyDatabasePassword: {{ PASSWORD }}
    persistence:
      existingClaim: {{ CLUSTER_NAME }}-postgres-disk-pvc
    master:
      nodeSelector:
        cloud.google.com/gke-nodepool: {{ NODE_POOL }}
  webHandlers:
    startupDelay: 10
  jobHandlers:
    startupDelay: 5
  workflowHandlers:
    startupDelay: 0
s3csi:
  nodeSelector:
    cloud.google.com/gke-nodepool: {{ NODE_POOL }}
nfs:
  storageClass:
    defaultClass: false
    name: nfs-{{ CLUSTER_NAME }}
  persistence:
    existingClaim: {{ CLUSTER_NAME }}-nfs-disk-pvc
    size: "{{ DISK }}Gi"
cvmfs:
  cache:
    alienCache:
      storageClass: nfs-{{ CLUSTER_NAME }}
rbac:
  enabled: false
persistence:
  nfs:
    name: {{ CLUSTER_NAME }}-nfs-disk
    size: "{{ DISK }}Gi"
    persistentVolume:
      extraSpec:
        gcePersistentDisk:
          pdName: {{ CLUSTER_NAME }}-nfs-pd
  postgres:
    name: {{ CLUSTER_NAME }}-postgres-disk
    size: "10Gi"
    persistentVolume:
      extraSpec:
        gcePersistentDisk:
          pdName: {{ CLUSTER_NAME }}-postgres-pd

