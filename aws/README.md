# AWS Benchmarking Experiment


## Setup

## Terraform

The `terraform` directory contains the Terraform plans used to provision the VPC, network, EC2 instances, and other Amazon infrastructure needed to run our Kubernetes cluster. Terraform will generate the Ansible inventory files needed to configure the instances once they are ready.

## Ansible

The `ansible` directory contains Ansible Playbooks, mostly copied from [Cloudman-boot](), used to install packages, configure Kubernetes (RKE) and set up Helm.

## Helm
The `helm` directory contains YAML files that are used as values files when installing or upgrading a Helm chart.  The `cloudcosts-common.yml` file contains values that are common to all Galaxy installations and `cloudcosts-template.yml.j2` is a Jinja2 template used to generate the values that are instance specific.  The `scripts/render_template.py` is used to generate the actual YAML file that will be used.