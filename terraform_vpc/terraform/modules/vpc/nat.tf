# route associations private
resource "aws_route_table_association" "private-subnets" {
  count = length(var.private-subnet)
  subnet_id      =  aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}
