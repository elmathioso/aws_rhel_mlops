# GPU Machine Learning on Red Hat with Terraform

## Overview
So you want to do machine learning on Red Hat. Good for you, you brave soul. 

In this example, we will be provisioning a Red Hat instance and installing machine learning libraries through Podman acting as a Docker clone.


## What you'll need
- Terraform installed on your computer.
- A Red Hat subscription.
- An AWS subscription with GPU access.
- AWS key credentials.
- About 20 minutes.

## Specifications
- RHEL 8.5
	- `amazon/RHEL_8.5-x86_64-SQL_2019_Express-2021.11.24`
- AWS `us-east-1`
- `g4dn.xlarge` 


## References
- Huge shoutout to Darryl Dias for creating [the backgrounder](https://darryldias.me/2021/nvidia-drivers-on-rhel-8/).


## Populating terraform.tfvars
`terraform.tfvars` is not shared - please create your own as part of the installation process.  This script refers to the following variables:

```
# terraform.tfvars
shared_config_files     = [<Location of AWS config file for CLI>]
shared_credential_files = [<location of AWS credentials file>]
key_name                = <name of key used on EC2>
private_key             = <location of local private key>
```

## Background
A few things to consider:

- RHEL 9 is generally [not supported by NVIDIA through containers](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#container-runtimes).
- RHEL [8.6 breaks on repo](https://nvidia.github.io/libnvidia-container/rhel8.5/libnvidia-container.repo). [8.5 is preferred](https://nvidia.github.io/libnvidia-container/rhel8.5/libnvidia-container.repo).

# Running the demo

Start by initializing and running Terraform:
```bash
./terraform init
./terraform plan
./terraform apply
```
a `hosts.cfg` file will be created.

Then, run the Ansible playbook:
```bash
ansible-playbook   \
  --private-key <PEM File Location>   \
  --inventory   hosts.cfg   \
  -e  'ansible_python_interpreter=/usr/bin/python3'      \
  playbook.yml
```

You will then be able to connect to the instance and download the appropriate container:

```bash
podman run \
  --security-opt=label=disable \
  --hooks-dir=/usr/share/containers/oci/hooks.d/ \
  tensorflow/tensorflow:latest-gpu \
  python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```