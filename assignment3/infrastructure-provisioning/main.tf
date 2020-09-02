provider "aws" {
  version    = "~> 2.8"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}


# ---  Create a VPC ------


resource "aws_vpc" "slice_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "slice-vpc"
  }
}



#--- Create Internet Gateway


resource "aws_internet_gateway" "slice_igw" {
  vpc_id = aws_vpc.slice_vpc.id
  tags = {
    Name = "slice-igw"
  }
}


# - Create Elastic IP


resource "aws_eip" "nat_eip" {
  vpc = true
}

# -- Create Subnet


data "aws_availability_zones" "azs" {
  state = "available"
}



#  create public subnet


resource "aws_subnet" "public-subnet-1a" {
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = "10.10.20.0/24"
  vpc_id                  = aws_vpc.slice_vpc.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-1a"
  }
}

#resource "aws_subnet" "public-subnet-1b" {
#  availability_zone       = "${data.aws_availability_zones.azs.names[1]}"
#  cidr_block              = "10.10.21.0/24"
#  vpc_id                  = "${aws_vpc.dc1.id}"
#  map_public_ip_on_launch = "true"
#  tags = {
#    Name = "public-subnet-1b"
#  }
#}


#  Create private subnet


resource "aws_subnet" "private-subnet-1a" {
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = "10.10.30.0/24"
  vpc_id            = aws_vpc.slice_vpc.id
  tags = {
    Name = "private-subnet-1a"
  }
}


# resource "aws_subnet" "private-subnet-1b" {
#  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
#  cidr_block        = "10.10.31.0/24"
#  vpc_id            = "${aws_vpc.dc1.id}"
#  tags = {
#    Name = "private-subnet-1b"
#  }
#}





# --------------  NAT Gateway

resource "aws_nat_gateway" "slice_ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet-1a.id
  tags = {
    Name = "Slice Nat Gateway"
  }
}




# ------------------- Routing ----------


resource "aws_route_table" "slice-public-route" {
  vpc_id = aws_vpc.slice_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.slice_igw.id
  }

  tags = {
    Name = "slice-public-route"
  }
}


resource "aws_default_route_table" "slice-default-route" {
  default_route_table_id = aws_vpc.slice_vpc.default_route_table_id
  tags = {
    Name = "slice-default-route"
  }
}



#--- Subnet Association -----

resource "aws_route_table_association" "publicsubnet1a" {
  subnet_id      = aws_subnet.public-subnet-1a.id
  route_table_id = aws_route_table.slice-public-route.id
}


#resource "aws_route_table_association" "arts1b" {
#  subnet_id      = "${aws_subnet.public-subnet-1b.id}"
#  route_table_id = "${aws_route_table.dc1-public-route.id}"
#}


resource "aws_route_table_association" "privatesubnet1a" {
  subnet_id      = aws_subnet.private-subnet-1a.id
  route_table_id = aws_vpc.slice_vpc.default_route_table_id
}

#resource "aws_route_table_association" "arts-p-1b" {
#  subnet_id      = "${aws_subnet.private-subnet-1b.id}"
#  route_table_id = "${aws_vpc.dc1.default_route_table_id}"
#}


#--- Security Groups ---------

resource "aws_security_group" "control_sg" {
  description = "Allow limited inbound external traffic on control machine"
  vpc_id      = aws_vpc.slice_vpc.id
  name        = "control_sg"

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "control-sg"
  }
}


resource "aws_security_group" "lb_sg" {
  description = "Allow limited inbound external traffic on LB machine"
  vpc_id      = aws_vpc.slice_vpc.id
  name        = "lb_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "lb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  description = "Allow limited inbound external traffic on app machine"
  vpc_id      = aws_vpc.slice_vpc.id
  name        = "app_sg"

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_security_group" "office_address" {
  description = "Allow limited inbound external traffic on app machine"
  vpc_id      = aws_vpc.slice_vpc.id
  name        = "office_address"

  ingress {
    protocol    = "tcp"
    cidr_blocks = [format("%s/32", var.office_address)]
    from_port   = 22
    to_port     = 22
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "office_address"
  }
}

resource "aws_instance" "control" {
  ami                         = var.basic_ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.control_sg.id, aws_security_group.office_address.id]
  subnet_id                   = aws_subnet.public-subnet-1a.id
  associate_public_ip_address = true
  tags = {
    Name        = "control"
    Environment = "production"
    type        = "control"
  }
}

output "control_id" {
  value = aws_instance.control.id
}


resource "aws_instance" "lb" {
  ami                         = var.basic_ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.lb_sg.id, aws_security_group.office_address.id]
  subnet_id                   = aws_subnet.public-subnet-1a.id
  associate_public_ip_address = true
  tags = {
    Name        = "LB"
    Environment = "production"
    type        = "loadbalancer"
  }
}

output "lb_id" {
  value = aws_instance.lb.id
}

resource "aws_instance" "app" {
  ami                    = var.basic_ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id, aws_security_group.office_address.id]
  subnet_id              = aws_subnet.private-subnet-1a.id
  tags = {
    Name        = "appserver"
    Environment = "production"
    type        = "appserver"
  }
}

resource "aws_eip" "control_eip" {
  #instance = "${terraform_remote_state.remote_state.output.control_id}"
  instance = aws_instance.control.id
  vpc      = true
}

resource "aws_eip" "lb_eip" {
  #instance = "${terraform_remote_state.remote_state.output.lb_id}"
  instance = aws_instance.lb.id
  vpc      = true
}

resource "aws_security_group_rule" "add-control-ip-to-control-sg" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [format("%s/32", aws_eip.control_eip.public_ip)]
    security_group_id = aws_security_group.control_sg.id
}

resource "aws_security_group_rule" "add-control-ip-to-lb-sg" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [format("%s/32", aws_eip.control_eip.public_ip)]
    security_group_id = aws_security_group.lb_sg.id
}

resource "aws_security_group_rule" "add-control-ip-to-app-sg" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [format("%s/32", aws_eip.control_eip.public_ip)]
    security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "add-lb-ip-to-app-sg" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [format("%s/32", aws_eip.lb_eip.public_ip)]
    security_group_id = aws_security_group.app_sg.id
}
