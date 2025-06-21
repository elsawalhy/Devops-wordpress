# the public subnet resource for wordpress
resource "aws_subnet" "subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet-1_cidr_block
  availability_zone = var.availability_zone


  tags = {
    Name = "${var.env_prefix}-subnet1"
  }
}
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw1"
  }
}

resource "aws_route_table" "myapp_rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb1"
  }
}

resource "aws_route_table_association" "a_rtb_subnet" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.myapp_rtb.id
}


# the priveate subnet resource for database

resource "aws_subnet" "subnet-2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet-2_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.env_prefix}-subnet2"
  }

}
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "myapp-ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet-1.id

  tags = {
    Name = "${var.env_prefix}-nat-gw"
  }
}

resource "aws_route_table" "database_rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myapp-ngw.id 
  }

  tags = {
    Name = "${var.env_prefix}-private-rtb"
  }
}

resource "aws_route_table_association" "a_rtb_private_subnet" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.database_rtb.id
}