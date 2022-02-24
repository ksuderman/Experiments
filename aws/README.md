# AWS Benchmarking Experiment

## TL ; DR

```
./scripts/render-cluster.sh m5a 2xlarge
eksctl create cluster -f ./clusters/m5a.2xlarge.yml --profile cost-modeling
cd ansible
ansible-playbook galaxy.helm.yml
```

## Setup


## Scripts

**render-template.py**<

Renders a Jinja2 template.  Parameters to be used in the template can be loaded from a file, or as `key=value` pairs on the command line.

```
./scripts/render-template.py --template template.yml --values values.yml foo=bar
./scripts/render-template.py -t template.yml -f values.yml foo=bar
```

**render-cluster.sh**

Generates the `cluster.yml` files used to launch EKS clusters.  Takes two parameters, the CPU class (m5, c5, etc) and size (xlarge, 2xlarge, etc.)

The Jinja2 template and values file are located in the `templates` directory.

```
./scripts/render-cluster.sh m5a 4xlarge
```

Ouput files are written to the `clusters` directory.

**update-galaxy.sh**

Does a `helm upgrade` on the cluster to apply a new `resource_sets` section to the `container_mapping_rules.yml` file.

```
./scripts/update-galaxy.yml ../rules/4x8.yml
```

**update-kubeconfig.sh**

Update the `~/.kube/config file to enable API access to the cluster via `kubectl`.

**wait-for-cluster.sh**

Blocks until the Kubternetes cluster is ready to process API requests.

**wait-for-galaxy.sh**

Blocks until the Galaxy handlers are online and ready.

## Terraform

*Experimental and not currently used.*

The `terraform` directory contains the Terraform plans used to provision the VPC, network, EC2 instances, and other Amazon infrastructure needed to run our Kubernetes cluster. Terraform will generate the Ansible inventory files needed to configure the instances once they are ready.

## Ansible

The `ansible` directory contains Ansible Playbooks, mostly copied from [Cloudman-boot](), used to install packages, configure Kubernetes (RKE) and set up Helm.

## Helm
The `helm` directory contains YAML files that are used as values files when installing or upgrading a Helm chart.  The `cloudcosts-common.yml` file contains values that are common to all Galaxy installations and `cloudcosts-template.yml.j2` is a Jinja2 template used to generate the values that are instance specific.  The `scripts/render_template.py` is used to generate the actual YAML file that will be used.