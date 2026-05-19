# eks.tf
resource "aws_eks_cluster" "lab" {
  name     = "lab-eks"
  version  = "1.35"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    endpoint_private_access = true
    endpoint_public_access  = true ## false - changed to allow public EKS API, Pods/Subnets = private, EKS API = public + can be restricted
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

#--- for Fargate (eks + no EC2 worker nodes)
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.lab.name
  fargate_profile_name   = "lab-fargate"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }
  
  selector {
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_policy
  ]
}

## Fargate profiles cannot be edited in-place. Terraform may need to destroy/recreate the profile.
## Simplest fix: create a second Fargate profile just for CoreDNS:
resource "aws_eks_fargate_profile" "coredns" {
  cluster_name           = aws_eks_cluster.lab.name
  fargate_profile_name   = "lab-coredns"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_policy
  ]
}

resource "aws_eks_fargate_profile" "default_apps" {
  cluster_name           = aws_eks_cluster.lab.name
  fargate_profile_name   = "lab-default-apps"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  selector {
    namespace = "default"
    labels = {
      app = "python-app"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_policy
  ]
}

resource "aws_eks_fargate_profile" "argocd" {
  cluster_name           = aws_eks_cluster.lab.name
  fargate_profile_name   = "lab-argocd"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  selector {
    namespace = "argocd"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_policy
  ]
}

resource "aws_eks_fargate_profile" "flask_app" {
  cluster_name           = aws_eks_cluster.lab.name
  fargate_profile_name   = "lab-flask-app"
  pod_execution_role_arn = aws_iam_role.eks_fargate.arn
  subnet_ids             = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  selector {
    namespace = "default"
    labels = {
      app = "flask-app"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_fargate_policy
  ]
}