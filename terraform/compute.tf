resource "aws_key_pair" "assignment" {
  key_name   = "${var.project_name}-ed25519"
  public_key = file(pathexpand(var.ssh_public_key_path))
  tags       = { Name = "${var.project_name}-ssh" }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.assignment.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2["web"].name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # enforce IMDSv2
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }
  depends_on = [aws_route_table_association.public]
  tags       = { Name = "${var.project_name}-web" }
}

resource "aws_instance" "database" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = var.db_instance_type
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.database.id]
  key_name                    = aws_key_pair.assignment.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2["database"].name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }
  depends_on = [aws_route_table_association.private]
  tags       = { Name = "${var.project_name}-database" }
}
