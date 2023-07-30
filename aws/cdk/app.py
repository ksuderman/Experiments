#!/usr/bin/env python3

from aws_cdk.aws_eks import Cluster, NodegroupRemoteAccess
import aws_cdk
from aws_cdk import Stack, App, aws_eks as eks
from aws_cdk import aws_ec2 as ec2

app = App()

stack = Stack(app, "MyEKSStack")

cluster = Cluster(
    stack, "EKS",
    cluster_name="MyEKSCluster",
    version=eks.KubernetesVersion.V1_21, #"1.21",
    default_capacity=0  # we want to manage capacity ourselves
)

node_group = cluster.add_nodegroup_capacity(
    "M6i2xlargeNodes",
    nodegroup_name="M6i2xlargeNodes",
    instance_types=[aws_cdk.aws_ec2.InstanceType.of(ec2.InstanceClass.M6I, ec2.InstanceSize.XLARGE2)], #["m6i.2xlarge"],
    min_size=2,
    remote_access=NodegroupRemoteAccess(ssh_key_name="aws-cloudcost-benchmark")
)

app.synth()
