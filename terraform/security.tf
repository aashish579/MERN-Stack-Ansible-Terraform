resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "HTTP public; SSH only from the learner public IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from learner IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  ingress {
    description = "HTTP for TravelMemory demo"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Outbound for package downloads and private DB connectivity"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-web-sg" }
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "MongoDB and SSH only reachable from public web EC2 security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH through web/bastion instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  ingress {
    description     = "MongoDB from application web instance only"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  egress {
    description = "Private subnet outbound via NAT for OS/MongoDB repositories"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-database-sg" }
}
