########################################################################################
#vpc
########################################################################################

resource "aws_vpc" "DevopsTestVPC" {
  cidr_block           = var.aws_vpc_cidr_block
  enable_dns_hostnames = "true"
  tags = {
    Name        = "devopstest"
    Environment = var.environment_tag
  }
}

########################################################################################
#internet gateway
########################################################################################

resource "aws_internet_gateway" "DevopsTestIGW" {
  vpc_id = aws_vpc.DevopsTestVPC.id
  tags = {
    Name        = "DevopsTestIGW"
    Environment = var.environment_tag
  }
}

########################################
## Elastic Ip for NAT
#####################################

resource "aws_eip" "DevopsTestEIP" {
  vpc        = true
  depends_on = [aws_internet_gateway.DevopsTestIGW]
}

########################################################################################
#NAT gateway for private instance
########################################################################################

resource "aws_nat_gateway" "DevopsTestNAT" {
  allocation_id = "${aws_eip.DevopsTestEIP.id}"
  subnet_id     = "${element(aws_subnet.DevopsTestSubnetPublic.*.id, 0)}"
  depends_on    = [aws_internet_gateway.DevopsTestIGW]
  tags = {
    Name        = "DevopsTestNAT"
    Environment = var.environment_tag
  }
}


##################################################################################
# DATA for availability zone
##################################################################################

data "aws_availability_zones" "available" {}


########################################################################################
# Public subnet
########################################################################################

resource "aws_subnet" "DevopsTestSubnetPublic" {
  count                   = "${var.subnet_count}"
  vpc_id                  = aws_vpc.DevopsTestVPC.id
  cidr_block              = element(var.aws_public_cidr_block, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  tags = {
    Name        = "DevopsTestSubnetPublic${count.index + 1}"
    Environment = var.environment_tag
  }
}

########################################################################################
# Private subnet
########################################################################################

resource "aws_subnet" "DevopsTestSubnetPrivate" {
  count                   = "${var.subnet_count}"
  vpc_id                  = aws_vpc.DevopsTestVPC.id
  cidr_block              = element(var.aws_private_cidr_block, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  tags = {
    Name        = "DevopsTestSubnetPrivate${count.index + 1}"
    Environment = var.environment_tag
  }
}

########################################################################################
#routetable for public
########################################################################################

resource "aws_route_table" "DevopsTestPublicRT" {
  vpc_id = aws_vpc.DevopsTestVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevopsTestIGW.id
  }
  tags = {
    Name        = "DevopsTestPublicRT"
    Environment = var.environment_tag
  }
}



########################################################################################
#routetable for private
########################################################################################

resource "aws_route_table" "DevopsTestPrivateRT" {
  vpc_id = aws_vpc.DevopsTestVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.DevopsTestNAT.id
  }
  tags = {
    Name        = "DevopsTestPrivateRT"
    Environment = var.environment_tag
  }
}
########################################################################################
#associating route table to public subnet
########################################################################################

resource "aws_route_table_association" "DevopsTestPublicRTA1" {
  count          = "${var.subnet_count}"
  subnet_id      = "${element(aws_subnet.DevopsTestSubnetPublic.*.id, count.index)}"
  route_table_id = aws_route_table.DevopsTestPublicRT.id

}

########################################################################################
#associating route table to private subnet
########################################################################################

resource "aws_route_table_association" "DevopsTestPrivateRTA1" {
  count          = "${var.subnet_count}"
  subnet_id      = "${element(aws_subnet.DevopsTestSubnetPrivate.*.id, count.index)}"
  route_table_id = aws_route_table.DevopsTestPrivateRT.id

}
