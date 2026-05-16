# elb-endpoint.tf
# Add an ELB VPC endpoint for LB controller to reach the ELBv2 AWS API from private Fargate nodes

resource "aws_vpc_endpoint" "elasticloadbalancing" {
  vpc_id              = aws_vpc.lab.id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "lab-elasticloadbalancing-endpoint"
  }
}