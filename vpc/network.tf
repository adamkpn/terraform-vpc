#----vpc/network.tf-----

#----vpc----
resource "aws_vpc" "tf_vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags = {
    Name = "tf-vpc"
  }
}

#----get all az's in given region----
data "aws_availability_zones" "tf_azs" {
  state = "available"
}

#----public subnet----
resource "aws_subnet" "tf_public_subnet" {
  count             = length(var.vpc_subnet_cidr_public)
  cidr_block        = "${var.vpc_subnet_cidr_public[count.index]}"
  vpc_id            = "${aws_vpc.tf_vpc.id}"
  availability_zone = "${data.aws_availability_zones.tf_azs.names[count.index]}"
  tags = {
    Name = "tf_public_subnet_${count.index+1}"
  }
}

#----private subnet----
resource "aws_subnet" "tf_private_subnet" {
  count             = length(var.vpc_subnet_cidr_private)
  cidr_block        = "${var.vpc_subnet_cidr_private[count.index]}"
  vpc_id            = "${aws_vpc.tf_vpc.id}"
  availability_zone = "${data.aws_availability_zones.tf_azs.names[count.index]}"
  tags = {
    Name = "tf_private_subnet_${count.index+1}"
  }
}

#----internet gateway----
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  tags = {
    Name = "tf_igw"
  }
}

#----elastic ip for nat gateway----
resource "aws_eip" "tf_eip_nat" {
  vpc = true
  tags = {
    Name = "tf_elastic_ip_for_nat"
  }
}

#----nat gateway----
resource "aws_nat_gateway" "tf_ngw" {
  allocation_id = "${aws_eip.tf_eip_nat.id}"
  subnet_id     = "${aws_subnet.tf_public_subnet[0].id}"
  depends_on    = ["aws_internet_gateway.tf_igw"]
  tags = {
    Name = "tf_nat_gateway"
  }
}

#----route table public----
resource "aws_route_table" "tf_public_rt" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tf_igw.id}"
  }
  tags = {
    Name = "tf_public_route_table"
  }
}

#----route table public association----
resource "aws_route_table_association" "tf_public_rt_assoc" {
  count          = "${length(var.vpc_subnet_cidr_public)}"
  subnet_id      = "${element(aws_subnet.tf_public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.tf_public_rt.id}"
}

#----route table private----
resource "aws_route_table" "tf_private_rt" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.tf_ngw.id}"
  }
  tags = {
    Name = "tf_private_route_table"
  }
}

#----route table private association----
resource "aws_route_table_association" "tf_private_rt_assoc" {
  count          = "${length(var.vpc_subnet_cidr_private)}"
  subnet_id      = "${element(aws_subnet.tf_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.tf_private_rt.id}"
}