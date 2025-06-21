resource "aws_security_group" "myapp-SG" {
  name   = "Myapp-SG"
  vpc_id = var.vpc_id


  egress {

    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]

  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env_prefix}-app-SG"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
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

resource "aws_instance" "myapp-server" {

  ami           = data.aws_ami.amazon_linux_imag.id
  instance_type = var.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.myapp-SG.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.ssh-key.key_name

  tags = {
    Name = "${var.env_prefix}-server"
  }

}
