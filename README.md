# ABM Experiments

This is an incubator for the scripts, plans, and playbooks needed to run Galaxy benchmarking experiments. 

This is a work in progress and will need a massive reorganization and clean up before it is ready for prime time.  Much of this documentation is aspirational in nature and describes what we want to do eventually, and not what is currently being done.

## Goals

The idea is to be able to `cd` to one of the subdirectories and:

- provision the infrastructure
- install Galaxy
- configure Galaxy (create user, upload data and workflows)
- run benchmarks
- save/copy metrics data
- destroy the infrastructure

## Provisioning

Each experiment should include a `provision.sh` script that is responsible for creating the actual infrastructure that Galaxy will run on.  The `provision.sh` script can use whatever means necessary to accomplish this task, whether it be Terraform plans, Ansible playbooks, or running `eksctl`/`gcloud`/`et al`.

## Installing Galaxy

This should essentiall be:

```
helm install galaxy galaxy/galaxy -n galaxy -f values.yml
```

Where the `values.yml` file contains the specific customizations need for installation on this cluster.

## Configuring Galaxy

TBD

1. Configure `abm`
  - Derive the Galaxy URL with `kubectl`
  - Create an admin user and get their API key
1. Upload the workflows
1. Upload the data

## Running benchmarks

TBD

## Saving metrics

TBD

# Cleaning up

TBD
