provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "ismile-storage"
    dynamodb_table = "tf-state-lock-dynamo"
    encrypt = false
    key    = "path/path/terraform-qa-tf-statefile"
    region = "us-east-2"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-vpc"
    Environment = "${var.app_environment}"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-vpc"
    Environment = "${var.app_environment}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-vpc"
    Environment = "${var.app_environment}"
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-vpc"
    Environment = "${var.app_environment}"
  }
}


variable "app_name" {
  default     = "ismile"
}

variable "app_environment" {
  default     = "QA"
}
