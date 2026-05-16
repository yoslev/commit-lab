resource "aws_security_group" "windows_ec2" {
  name        = "lab-windows-ec2-sg"
  description = "Windows EC2 access via SSM only"
  vpc_id      = aws_vpc.lab.id

  # No inbound rules needed for SSM

  egress {
    description = "Allow HTTPS outbound for SSM endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }

  egress {
    description = "Allow HTTP to internal ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }
  
  tags = {
    Name = "lab-windows-ec2-sg"
  }
}