resource "aws_vpc" "play" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "eks_play",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_subnet" "play" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.play.id

  tags = tomap({
    "Name"                                      = "eks_play",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_internet_gateway" "play" {
  vpc_id = aws_vpc.play.id

  tags = {
    Name = "eks_play"
  }
}

resource "aws_route_table" "play" {
  vpc_id = aws_vpc.play.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.play.id
  }
}

resource "aws_route_table_association" "play" {
  count = 2

  subnet_id      = aws_subnet.play.*.id[count.index]
  route_table_id = aws_route_table.play.id
}
