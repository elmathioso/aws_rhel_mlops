terraform {
  required_providers {
    aws = {}
  }
}


# Declare variables to be loaded from terraform.tfvars
variable "shared_config_files" {}
variable "shared_credentials_files" {}
variable "key_name" {}
variable "private_key" {}


# Provide access to the AWS management account 
provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = var.shared_config_files
  shared_credentials_files = var.shared_credentials_files
  profile                  = "default"
}


resource "aws_instance" "new_rhel" {

  # amazon/RHEL_8.5-x86_64-SQL_2019_Express-2021.11.24 
  ami           = "ami-03c1de4e158cf48d4"	

  # NVIDIA T4 (TU104, 2560 CUDA Cores, 16 GB RAM)
  instance_type = "g4dn.xlarge"				    
  key_name		  = var.key_name

  tags = {
    Name = "RHEL 8.5"
  }

  # Enough space will be required for the upcoming containers  
  root_block_device  {
	  volume_size = "100"  
  }
  
  connection {
    type        = "ssh"
    host        = aws_instance.new_rhel.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key)
  }

}


# Get IDs and IP addresses
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.new_rhel.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.new_rhel.public_ip
}



# Export data to Ansible-ready file 
# and then execute the playbook
resource "local_file" "hosts_cfg" {
  content = templatefile("templates/hosts.tpl",
  {
    rhel_ml_hosts = aws_instance.new_rhel.*.public_ip
  })
  filename = "Ansible/hosts.cfg"

  # Run the playbook
  # You can run it from within the provisioner, 
  # or natively through `run_ansible.sh`
  # provisioner "local-exec" {
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ${var.private_key} --inventory Ansible/hosts.cfg -e  'ansible_python_interpreter=/usr/bin/python3' Ansible/playbook.yml"
  # }

}

