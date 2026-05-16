# sts-endpoint.tf
# For private Fargate pod to access to AWS STS for IRSA
# To solve Problem: Ingress cannot assign an address

resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.lab.id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "lab-sts-endpoint"
  }
}