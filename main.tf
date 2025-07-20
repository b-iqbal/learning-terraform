data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog-new-security-group.security_group_id]

  tags = {
    Name = "Hi, There!"
  }
}

module "blog-new-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name    = "blog_new_sg"

  vpc_id = data.aws_vpc.default.id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # Allow all outbound traffic
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
