# AWS Benchmarking Experiment


## Setup

## Terraform

## Ansible

## Helm
The `helm` directory contains YAML files that are used as values files when installing or upgrading a Helm chart.  The `cloudcosts-common.yml` file contains values that are common to all Galaxy installations and `cloudcosts-template.yml.j2` is a Jinja2 template used to generate the values that are instance specific.  The `scripts/render_template.py` is used to generate the actual YAML file that will be used.