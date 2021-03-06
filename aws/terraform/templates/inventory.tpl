# The file is automatically generated by Terraform.
[localhost]
127.0.0.1 ansible_connection=local ansible_python_interpreter="/usr/bin/python3"

[controllers]
${name} ansible_ssh_host=${ip}

[agents]

[nodes:children]
controllers
agents

[rke_cluster:children]
controllers
agents

[all:vars]
ansible_ssh_port=22
ansible_user='ubuntu'
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file=${key}
ansible_python_interpreter="/usr/bin/python3"

