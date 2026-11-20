variable "aws_region" {
  description = "Region for AWS resources, not the Identity Center SSO region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for AWS resource names."
  type        = string
  default     = "travelmemory-lab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,27}$", var.project_name))
    error_message = "project_name must be 3-28 lower-case letters, digits or hyphens, beginning with a letter."
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.42.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.42.2.0/24"
}

variable "allowed_ssh_cidr" {
  description = "YOUR current public IPv4 followed by /32; never set 0.0.0.0/0 for SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) && tonumber(split("/", var.allowed_ssh_cidr)[1]) == 32
    error_message = "Set an IPv4 /32 such as 203.0.113.10/32 for SSH access."
  }
}

variable "ssh_public_key_path" {
  description = "Local path to your WSL-generated ED25519 public key. Only the public half is sent to AWS."
  type        = string
  default     = "~/.ssh/mern_hero_vired.pub"
}

variable "web_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "db_instance_type" {
  type    = string
  default = "t3.small"
}
