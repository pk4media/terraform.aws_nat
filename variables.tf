variable "name" {
  default     = "nat"
  description = "NAT name"
}

variable "environment" {
  default     = "development"
  description = "Environment (development, staging, production)"
}

variable "region" {
  description = "The AWS region to create the NAT resources in"
}

variable "vpc_id" {
  description = "ID of the VPC to create the NAT resources in"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  description = "The CIDR blocks of the public Subnets"
}

variable "subnet_ids" {
  description = "The IDs of the public Subnets"
}

variable "user" {
  default     = "ubuntu"
  description = "The user to use to ssh into the instances"
}

variable "instance_type" {
  default     = "t2.small"
  description = "The EC2 instance type to launch"
}

variable "ec2_key_name" {
  description = "The EC2 key to use in creating the instances (must exist)"
}

variable "private_key" {
  description = "The contents of the EC2 key associated with the instances"
}

variable "bastion_host" {
  description = "The bastion host to connect through"
}
variable "bastion_user" {
  description = "The user on the bastion host"
}
variable "bastion_security_group_id" {
  description = "The Security Group used to allow the bastion to connect"
}
