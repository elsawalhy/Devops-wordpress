
resource "aws_security_group" "databse-SG" {
  name   = "DB-SG"
  vpc_id = var.vpc_id


  egress {

    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ var.wordpress_sg]
    # cidr_blocks = ["0.0.0.0/0"]
  }



  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-database-SG"
  }
}

resource "aws_key_pair" "ec2-key" {
  key_name   = "db-key"
  public_key = var.public_key
}

data "aws_ami" "amazon_linux_imag" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "database-server" {

  ami           = data.aws_ami.amazon_linux_imag.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.databse-SG.id]
  key_name = aws_key_pair.ec2-key.key_name
  tags = {
    Name = "${var.env_prefix}-database"
  }

}
