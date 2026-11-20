output "aws_region" {
  value       = var.aws_region
  description = "AWS resource region"
}
output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_id" {
  value = aws_subnet.public.id
}
output "private_subnet_id" {
  value = aws_subnet.private.id
}
output "public_route_table_id" {
  value = aws_route_table.public.id
}
output "private_route_table_id" {
  value = aws_route_table.private.id
}
output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}
output "web_instance_id" {
  value = aws_instance.web.id
}
output "database_instance_id" {
  value = aws_instance.database.id
}
output "web_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Open http://WEB_PUBLIC_IP/ after Ansible deployment"
}
output "web_private_ip" {
  value = aws_instance.web.private_ip
}
output "database_private_ip" {
  value       = aws_instance.database.private_ip
  description = "MongoDB is only accessible inside the VPC"
}
output "application_url" {
  value = "http://${aws_instance.web.public_ip}"
}
output "allowed_ssh_cidr" {
  value = var.allowed_ssh_cidr
}
output "ssh_user" {
  value = "ubuntu"
}
