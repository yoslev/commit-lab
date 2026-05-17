Solution (Y.Lev)

Networking Overview


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
