# Fetch AZs 
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "gatus_vpc" {
    cidr_block = var.my_vpc_cidr

    tags = {Name = "${var.project_name}-vpc"}
}

## Subnets using cidrsubnet function

resource "aws_subnet" "private" {
    count             = var.az_count
    cidr_block        = cidrsubnet(aws_vpc.gatus_vpc.cidr_block, 6, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    vpc_id            = aws_vpc.gatus_vpc.id

    
}

resource "aws_subnet" "public" {
    count                   = var.az_count
    cidr_block              = cidrsubnet(aws_vpc.gatus_vpc.cidr_block, 6, var.az_count + count.index)
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    vpc_id                  = aws_vpc.gatus_vpc.id
    map_public_ip_on_launch = true
}

# IGW

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.gatus_vpc.id

    tags = {Name = "${var.project_name}-igw"}
}

## Gateways

resource "aws_route" "internet_access" {
    route_table_id         = aws_vpc.gatus_vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
    
}

# 
resource "aws_eip" "gw" {
    count      = var.az_count
    domain = "vpc"
    depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "main" {
    count         = var.az_count
    subnet_id     = element(aws_subnet.public.*.id, count.index)
    allocation_id = element(aws_eip.gw.*.id, count.index)

    tags = { Name = "${var.project_name}-nat"}
}

## Route table association 

resource "aws_route_table" "private" {
    count  = var.az_count
    vpc_id = aws_vpc.gatus_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
    }
    
    tags = {Name = "${var.project_name}-private-rt"}
}

# 
resource "aws_route_table_association" "private" {
    count          = var.az_count
    subnet_id      = element(aws_subnet.private.*.id, count.index)
    route_table_id = element(aws_route_table.private.*.id, count.index)

 
}
