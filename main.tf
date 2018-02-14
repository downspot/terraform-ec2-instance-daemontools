variable "aws_region" {}
variable "instance_type" {}
variable "key_name" {}
variable "vpc_security_group_ids" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "tag_env" {}
variable "tag_name" {}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "terraform_remote_state" "network" {
  backend       = "s3"
  workspace     = "${terraform.workspace}"

  config {
    bucket      = "example-terraform"
    key         = "terraform.tfstate"
    region      = "${var.aws_region}"
  }
}

terraform {
  backend "s3" {
    bucket  = "example-terraform"
    key       = "terraform.tfstate"
    region   = "us-east-1"
  }
}

data "template_file" "user_data" {
  template = "${file("user_data.sh")}"
}

resource "aws_instance" "example-contextual-bandit" {
  ami 			 = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  iam_instance_profile   = "${var.iam_instance_profile}"
  user_data              = "${data.template_file.user_data.rendered}"

  tags {
    Name = "${var.tag_name}"
    ProductCode = "PRD00001453"
    InventoryCode = "example-contextual-bandit"
    Environment = "${var.tag_env}"
  }
}

resource "aws_cloudwatch_metric_alarm" "example-contextual-bandit" {
    alarm_name          = "${aws_instance.example-contextual-bandit.id}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "StatusCheckFailed_System"
    namespace           = "AWS/EC2"
    period              = "60"
    statistic           = "Maximum"
    threshold           = "1.0"
    alarm_description   = "Created from EC2 Console"
    alarm_actions       = ["arn:aws:automate:us-east-1:ec2:recover"]
      dimensions {
        InstanceId 	= "${aws_instance.example-contextual-bandit.id}"
    }
}


output "image_id" {
    value = "${data.aws_ami.amazon_linux.id}"
}

output "id" {
  value       = ["${aws_instance.example-contextual-bandit.id}"]
}

output "private_ip" {
  value       = ["${aws_instance.example-contextual-bandit.private_ip}"]
}
