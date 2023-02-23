# Configure Network for Tenacity IT Group

# Create 1 VPC
resource "aws_vpc" "Tenacity-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "Tenacity-VPC"
    environment = "Test"
  }
}

# Creating 2 Public Subnets
resource "aws_subnet" "Prod-Pub-Sub1" {
  vpc_id            = aws_vpc.Tenacity-VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name        = "Prod-Pub-Sub1"
    environment = "Test"
  }
}

resource "aws_subnet" "Prod-Pub-Sub2" {
  vpc_id            = aws_vpc.Tenacity-VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name        = "Prod-Pub-Sub2"
    environment = "Test"
  }
}

# Creating 2 Private Subnets
resource "aws_subnet" "Prod-Priv-Sub1" {
  vpc_id            = aws_vpc.Tenacity-VPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name        = "Prod-Priv-Sub1"
    environment = "Test"
  }
}

resource "aws_subnet" "Prod-Priv-Sub2" {
  vpc_id            = aws_vpc.Tenacity-VPC.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name        = "Prod-Priv-Sub2"
    environment = "Test"
  }
}

# Creating Public Route Table
resource "aws_route_table" "Prod-Pub-Route-Table" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name        = "Prod-Pub-Route-Table"
    environment = "Test"
  }
}

# Associate Subnet Pub 1 and 2 to the Public Route Table
resource "aws_route_table_association" "Public_Subnet1_Association" {
  subnet_id      = aws_subnet.Prod-Pub-Sub1.id
  route_table_id = aws_route_table.Prod-Pub-Route-Table.id
}
resource "aws_route_table_association" "Public_Subnet2_Association" {
  subnet_id      = aws_subnet.Prod-Pub-Sub2.id
  route_table_id = aws_route_table.Prod-Pub-Route-Table.id
}
# Creating Private Route Table
resource "aws_route_table" "Prod-Priv-Route-Table" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name        = "Prod-Priv-Route-Table"
    environment = "Test"
  }
}

# Associate Subnets 1 and 2 to the Private Route Table
resource "aws_route_table_association" "Private_Subnet1_Association" {
  subnet_id      = aws_subnet.Prod-Priv-Sub1.id
  route_table_id = aws_route_table.Prod-Priv-Route-Table.id
}
resource "aws_route_table_association" "Private_Subnet2_Association" {
  subnet_id      = aws_subnet.Prod-Priv-Sub2.id
  route_table_id = aws_route_table.Prod-Priv-Route-Table.id
}
# internet gateway
resource "aws_internet_gateway" "Prod-Igw" {
  vpc_id = aws_vpc.Tenacity-VPC.id
}
# internet gateway association with Public RT 
resource "aws_route" "Igw-association-route" {
  route_table_id         = aws_route_table.Prod-Pub-Route-Table.id
  gateway_id             = aws_internet_gateway.Prod-Igw.id
  destination_cidr_block = "0.0.0.0/0"
}
# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet
resource "aws_eip" "Nat_eip" {
  vpc = true
}

# Create NAT gateway
resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.Nat_eip.id
  subnet_id     = aws_subnet.Prod-Pub-Sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

