# ec2-windows.tf

data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows" {
  ami                         = data.aws_ami.windows_2022.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.windows_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.windows_ssm.name
  associate_public_ip_address = false

  # No key_name because key-pair is not allowed

  tags = {
    Name = "lab-windows-ssm"
  }
}