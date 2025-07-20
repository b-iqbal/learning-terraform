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


module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1", "eu-west-2", "eu-west-3"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog-new-security-group.security_group_id]

  subnet_id = module.blog_vpc.public_subnets[0]

  tags = {
    Name = "Hi, There!"
  }
}

module "blog-new-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name    = "blog_new_sg"

  vpc_id = module.blog_vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # Allow all outbound traffic
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
