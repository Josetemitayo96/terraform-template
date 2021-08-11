output "id" {
  value = aws_vpc.DevopsTestVPC.id
}

output "public_subnets" {
  value = aws_subnet.DevopsTestSubnetPublic
}

output "private_subnets" {
  value = aws_subnet.DevopsTestSubnetPrivate
}

output "public_subnets_ids" {
  value = aws_subnet.DevopsTestSubnetPublic.*.id
}

output "private_subnets_ids" {
  value = aws_subnet.DevopsTestSubnetPrivate.*.id
}

output "VPC_cidr_block" {
  value = aws_vpc.DevopsTestVPC.cidr_block

}