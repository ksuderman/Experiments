# AWS Benchmarking Experiment

## TL ; DR

```
./bin/cluster create c5a 2xlarge
cd ansible
ansible-playbook galaxy-helm.yml
cd -
./bin/bootstrap.sh c5a2xlarge
abm experiment run experiment.yml  # Assumes we have written this to use the new cluster
./bin/cluster delete c5a 2xlarge
```

 :bulb: The `bin/cluster create` command will write a cluster configiuration file to the `clusters` directory. This file is used by the `bin/cluster delete` command. The following command are equivalent to running the above `bin/cluster delete` command.

 ```
 eksctl delete cluster -f clusters/c5a2xlarge.yml --profile cost-modeling
 eksctl delete cluster --name c5a2xlarge --profile cost-modeling
 ```

## Setup

Create a virtual env and install `ansible` and `abm`.

```
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install ansible
pip install --extral-index-url https://test.pypi.org gxabm
abm version
```

> :bulb: Once the `gxabm` package has been released to PyPi the `--extra-index-url` argument can be removed from the above `pip install` command.

## Pricing Information

The latest AWS price list can be fetched from [https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/index.json]() **BUT DON'T CLICK THAT LINK!!!** It is a 2.7G JSON file.

Another source, but I don't know if this is current as I found it on [StackOverflow](https://stackoverflow.com/questions/7334035/get-ec2-pricing-programmatically) 

- http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js

The `bin/pricing.py` script contains an example of using the `boto3` library to query the AWS Pricing API, but it returns a huge amount of information.
 
## Scripts

**bin/cluster**

This is typically the only script that will be called to launch an EKS cluster.  The `bin/cluster` script expects the instance type to be specified as two paramters:

- **cpuType**<br/>
The CPU type family, for example cost optimized or memory optimized, Intel or AMD, etc.  For example `c5i`, `m5a`.
- **cpuSize**</br>
The number of cores per instance.  For example `2xlarge`, `8xlarge`.

```
bin/cluster c5 4xlarge
```

**render-template.py**

Renders a Jinja2 template.  Parameters to be used in the template can be loaded from a file, or as `key=value` pairs on the command line.

```
./scripts/render-template.py --template template.yml --values values.yml foo=bar
./scripts/render-template.py -t template.yml -f values.yml foo=bar
```

**render-cluster.sh**

Generates the `cluster.yml` files used to launch EKS clusters.  Takes two parameters, the CPU class (m5, c5, etc) and size (xlarge, 2xlarge, etc.)

This script calls the `bin/render-template.py` script with the template and values to generate the cluster configuration for an AWS EKS cluster. The Jinja2 template and values file are located in the `templates` directory.

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