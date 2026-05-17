Solution (Y.Lev)

Networking Overview in file: Net-topology-design.txt (show in Notepad++ only)


# EKS Fargate Microservices Lab

## Overview

This lab demonstrates a private AWS Kubernetes platform running on Amazon EKS with AWS 'Fargate type nodes' ("serverless" not ec2 nodes), 
internal Application Load Balancers (ALB)
HTTPS termination using ACM certificates
Helm deployments
Python Flask-based microservices.

Application is comrised of:
 - Frontend: Python Flask application 
 - Backend : Python Flask application 
 - Postgres RDS DB aws service
 both Python applications packed in a docker image loaded ito aws ecr using Helm chart.

The environment was designed as a fully private architecture using internal networking and VPC endpoints.

All resource are built by Terraform.
A windows ec2 machine is also a part of this 

## Folders structure
Folders:

App-backend: backend application code (app.py) + Dockerfile + Python requirements.txt + b.bat (to build and puch into ECR)

App-backend-Helm: backend application Helm charts + h-inst.bat + h-up.bat with helm install and helm upgrade commands

App-frontend: frontend application code (app.py) + Dockerfile + Python requirements.txt + b.bat (to build and puch into ECR)

App-frontend-Helm: frontend application Helm charts + h-inst.bat + h-up.bat with helm install and helm upgrade commands

argocd: To install argocd
           argocd-ingress.yaml + argocd-install.yaml 
		   inst-argocd.bat + inst-ingress.bat 
		   images were pulled and pushed into ECR
		   (argoCD was not used yet)
		   
aws-lab-TF: aws resources creation Terraform files

aws-logging: ConfigMap to add cloudwatch logs

cert: self signed certificates generated

monitorring: values.yaml file to install prometheus and 
             TEST CHART
               helm template monitoring prometheus-community/kube-prometheus-stack -n monitoring -f monitoring-values.yaml 
             
             DEPLOY
               helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f monitoring-values.yaml
             
             IF FAILES:
               kubectl delete job monitoring-kube-prometheus-admission-create -n monitoring
               kubectl delete job monitoring-kube-prometheus-admission-patch -n monitoring --ignore-not-found
               helm uninstall monitoring -n monitoring
               kubectl delete ns monitoring
             
             helm template monitoring prometheus-community/kube-prometheus-stack -n monitoring -f monitoring-values.yaml 
             helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f monitoring-values.yaml --create-namespace 


---

# Architecture

```text
Windows EC2 Instance
(Browser / curl / kubectl)
        |
        | HTTPS
        v
+----------------------+
| Internal AWS ALB     |
| (Frontend Ingress)   |
+----------------------+
        |
        v
+----------------------+
| Frontend Flask App   |
| EKS Fargate Pod      |
+----------------------+
        |
        | HTTP via K8s Service DNS
        v
+----------------------+
| Backend Flask App    |
| EKS Fargate Pod      |
+----------------------+
        |
        | Future Integration
        v
+----------------------+
| Amazon RDS           |
+----------------------+
```

---

# Components

## AWS Infrastructure

- Amazon EKS
- AWS 'Fargate type nodes'
- Internal Application Load Balancers
- AWS ACM
- VPC Endpoints
- Amazon ECR
- Windows EC2 management instance

---

## Kubernetes Components

- CoreDNS
- AWS Load Balancer Controller
- ArgoCD
- Frontend Flask application
- Backend Flask application

---

# Networking

## VPC

Private VPC with:

- Private subnets
- Internal ALBs only
- No public application exposure

Example CIDR:

```text
10.0.0.0/16
```

Both subnets do not have public ip:
```text
resource "aws_subnet" "private_a" {
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false         <--

resource "aws_subnet" "private_b" {
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false         <--

```
# Network topology design

```text
                                                                   ┌─────────────┐
                                                                   │ My home PC  │ aws ssm start-session --target..
                                                                   └─────────────┘
                                                                        │
                                                                        │
 ┌────────────────────────────────────────────────┐                     │
 │     VPC (lab-vpc)                              │ (10.0.0.0/16)       │
 │                           ┌────────────────┐   │                     │
 │                           │ ec2 windows PC │   │                     │
 │                           └────────────────┘   │                     │
 │                                                │                     │
 │                                                │                     │
 │  Private Subnets                               │                     │
 │  lab-private-a lab-private-b                   │                     ▼
 │  (10.0.1.0/24, 10.0.2.0/24) --------------------------------------> SSM
 │                                                │
 │                                              ──> VPC Endpoints → ec2, ssm, ssmmessages, ec2messages, ecr_api, ecr_dkr, s3, elasticloadbalancing, sts
 │                                                │
 │              k8s cluster                       │
 │              "lab-eks"                         │
 │  ┌───────────────────┐ ┌─────────────────────┐ │
 │  │ 2 pods: flask-app │ │ 1 pod: frontend-app │ │
 │  └───────────────────┘ └─────────────────────┘ │
 └────────────────────────────────────────────────┘
     ▲                                    ▲ 
     │                                    │
    TG k8s-default-flaskapp              TG k8s-default-frontend
     ▲                                    ▲
     │                                    │
┌─────────┐                           ┌─────────┐
│  BE ALB │ k8s-default-flaskapp (BE) │  FE ALB │ k8s-default-frontend (FE)
└─────────┘                           └─────────┘
     ▲ ALB listener: port 443             ▲ ALB listener: port 443
     │                                    │

```

---

# AWS VPC Endpoints

Private VPC endpoints configured for:

- ECR API
- ECR DKR
- SSM
- EC2
- ELB
- STS
- CloudWatch Logs

This enabled fully private Fargate networking and image pulls from ECR.

---

# EKS

## Fargate Profiles

Fargate profiles configured for:

- kube-system
- default
- argocd
---

# AWS Load Balancer Controller

The AWS Load Balancer Controller runs inside the cluster in the `kube-system` namespace.

Responsibilities:

- Watches Kubernetes Ingress resources
- Creates AWS ALBs
- Creates listeners
- Creates target groups
- Registers pod IPs
- Manages ALB security groups
- Synchronizes Kubernetes desired state with AWS infrastructure

---

# Backend Application

## Description

Flask-based backend service exposing:

```text
/
```

Future integration planned with Amazon RDS.

---

## Backend Service DNS

```text
http://flask-app-service.default.svc.cluster.local
```

---

# Frontend Application

## Description

Frontend Flask application that:

- Polls backend service every 5 seconds
- Stores latest backend value
- Exposes latest value over HTTPS

Example response:

```text
Hello Lab-commit 5
```

---

# Helm Deployments

Applications packaged as Helm charts.

Each chart contains:

- Deployment
- Service
- Ingress
- values.yaml
- Chart.yaml

---

# Ingress Configuration
Ingress annotations helps aws ALB controller to build ALB listeners, target groups, security-group, etc.. and assign certificates (self signed)
As ingress is annotated:
```text
        kubectl annotate ingress flask-app-ingress -n default force-reconcile="%time%" --overwrite
```
ALB controller is triggered to configure.

Ingress annotations:

```yaml
alb.ingress.kubernetes.io/scheme: internal
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/backend-protocol: HTTP
alb.ingress.kubernetes.io/healthcheck-path: /health
alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
alb.ingress.kubernetes.io/manage-backend-security-group-rules: "true"
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80},{"HTTPS":443}]'
alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-2:123456789012:certificate/03b53f8b-cd37-452f-a5ad-109d549ffda2
alb.ingress.kubernetes.io/ssl-redirect: "443"

```

---

# HTTPS / TLS

HTTPS termination is performed at the ALB layer.

Certificates:

- Self-signed certificates
- Imported into AWS ACM
- Attached to ALB HTTPS listeners

Frontend and backend services both support:

- HTTP listener (80)
- HTTPS listener (443)

---

# Internal DNS / Service Discovery

Applications communicate using Kubernetes DNS.

Example:

```text
http://flask-app-service.default.svc.cluster.local
```

# Route53 DNS
Route53 CNAME dns records were added to improve surf experience.


Route53 Hosted zone name: lab.local

## Records:
```text
flaskapp.lab.local           - to BE listener, https://flaskapp.lab.local from Windows ec2 instance only
lab-commit-task-fe.lab.local - to FE listener, https://lab-commit-task-fe.lab.local from Windows ec2 instance only
```

You can surf the above url's from Windows ec2 instance only as network is closed.
---

# ArgoCD

ArgoCD deployed into EKS and exposed internally using ALB ingress and HTTPS.

Used for:

- GitOps
- Kubernetes application management
- Deployment visualization

---

# Container Registry

Docker images stored in Amazon ECR.

Images:

- frontend-lab
- backend Flask application

---

# Troubleshooting Performed
Overall

As network is provate imagse that could not be pulled directly into EKS 'Fargate type nodes' were manually puslled, tagged and pushed into ECR.

## CoreDNS Scheduling Issues

Resolved Fargate scheduling and taint problems to load Prometheus/Grafana.
Added         
```text
tolerations:
          - operator: Exists
```
into modules in monitoring-values.yaml 

Resolved 'too many nodes' issue by commenting out modules.

---

## ALB Provisioning Failures

Resolved:

- missing VPC endpoint access
- subnet tagging issues
- controller reconciliation issues

---

## HTTPS Listener Failures

Resolved:

- incorrect ACM certificates
- invalid SAN configuration
- ingress annotation issues

---

## ImagePullBackOff

Resolved:

- ECR connectivity
- Fargate networking
- VPC endpoint configuration

---

## Target Group Health Issues

Resolved:

- backend protocol mismatch
- health check configuration
- stale target registration

---

# Useful Commands

## Check ingress

```bash
kubectl get ingress -A
```

---

## Check ALB listeners

```bash
aws elbv2 describe-listeners \
  --region us-west-2 \
  --load-balancer-arn <ALB_ARN>
```

---

## Check target health

```bash
aws elbv2 describe-target-health \
  --region us-west-2 \
  --target-group-arn <TARGET_GROUP_ARN>
```

---

## Force ingress reconcile

```bash
kubectl annotate ingress frontend-app-ingress \
  force-reconcile="%random%" \
  --overwrite
```

---

## View ALB controller logs

```bash
kubectl logs -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller
```

---

# Final Result

Successfully implemented:

- EKS on Fargate
- Internal ALBs
- HTTPS termination
- Helm deployments
- Frontend/backend microservices
- Kubernetes internal DNS
- ArgoCD
- AWS Load Balancer Controller
- ACM integration
- Private networking architecture
- Ready architecture for RDS integration



