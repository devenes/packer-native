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

# AMI names must be unique else it will throw an error.
source "amazon-ebs" "ubuntu_docker" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = var.ssh_username
}

build {
  name = "packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu_docker"
  ]

  provisioner "shell" {

    inline = [
      "echo Install Open JDK 8 - START",
      "sleep 10",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jdk",
      "echo Install Open JDK 8 - SUCCESS",
      "sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      "echo Install Docker - SUCCESS",
      "sudo apt -y remove needrestart",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "sudo apt-add-repository -y --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
    ]
  }
}
