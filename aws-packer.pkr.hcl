packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "packer-aws-docker"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu_docker" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = var.ssh_username
}

build {
  name = "packer-ubuntu-docker"
  sources = [
    "source.amazon-ebs.ubuntu_docker"
  ]

  provisioner "shell-local" {
    inline = [
      "echo Install Docker - START",
      # "sleep 10",
      "apt-get update",
      "apt-get install -y docker.io",
      # "apt-get upgrade -y",
      # "apt install -y docker.io",
      # "echo Install Docker - SUCCESS",
      # "usermod -aG docker ubuntu",
      # "newgrp docker",
      # "echo Add ubuntu to docker group - SUCCESS",
      "systemctl enable docker",
      # "echo Enable docker service - SUCCESS",
    ]
  }
}
