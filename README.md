# Gatus ECS Deployment Project

A production-ready infrastructure-as-code project for deploying **[Gatus](https://github.com/TwiN/gatus)** on **AWS ECS (Fargate)** using **Terraform** and **GitHub Actions CI/CD (OIDC)**.

---

## What is Gatus?

**Gatus** is a lightweight uptime monitoring and status dashboard that helps DevOps / platform teams:

- **Monitor services**: Check HTTP/TCP/ICMP endpoints on a schedule
- **Validate health**: Use real health checks (e.g. `/health`) to confirm service availability
- **Visualize status**: Simple UI to see uptime, latency, and incidents at a glance
- **Alerting-ready**: Integrates with common notification channels (depending on config)

Gatus is a great “real-world” demo app because it naturally exercises production concerns like **load balancing, health checks, private networking, TLS, logging, and safe deployments**.

---

## What This Project Does

This project deploys Gatus as a **production-style, cloud-hosted application** on AWS. Instead of running it locally or on a single VM, this setup provides:

- **Scalable hosting**: Runs on **AWS ECS Fargate** (serverless containers)
- **High availability**: Deployed across **multiple Availability Zones**
- **Secure access**: **HTTPS** via **ACM** + **ALB** with a custom domain (Route 53)
- **Private compute**: Tasks run in **private subnets** (no public IPs)
- **Automated delivery**: GitHub Actions workflows for build → scan → plan → apply
- **Security checks**: Container scanning (**Trivy**) + IaC scanning (**Checkov/TfSec**)

---

## Architecture Diagram

![AWS Architecture Diagram](images/architecture.png)

*Architecture diagram showing the complete AWS infrastructure setup for the Gatus application deployment on ECS Fargate.*

## Deployment Status

![Terraform Deploy Pipeline](images/deploy_workflow_success.png)

This repo uses separate GitHub Actions workflows:

- **Build & Push (CI):** Builds the Docker image, runs a **Trivy** vulnerability scan, then pushes to **AWS ECR**.
- **Terraform Deploy (CD):** Runs **Checkov** (IaC scan), then Terraform `fmt/validate/plan/apply`, followed by a `/health` check.
- **Terraform Destroy:** Manual teardown workflow to destroy infrastructure (includes state-lock unlock + retry).

![Gatus Web Application](images/app.png)

*The Gatus web application running in production with HTTPS encryption on the custom domain https://tm.yassinsuleiman.com, deployed on AWS ECS Fargate.*

## Description of the Project

This project sets up the infrastructure needed to run Gatus on AWS Elastic Container Service (ECS). It includes modular Terraform configurations for all AWS resources, automated deployment through GitHub Actions, and a Docker-based container setup.

The infrastructure is production-ready with load balancing, SSL/TLS certificates, high availability across multiple availability zones, and security best practices built in. The architecture uses ECS Fargate for serverless container hosting, which scales automatically based on demand.

Key features include automated deployments that trigger on pushes to the main branch, HTTPS encryption with ACM certificates, private subnets for application security, ""CloudWatch logging and monitoring,"" GitHub Actions CI/CD with OIDC authentication, and reusable Terraform modules for VPC, ECS, ALB, ECR, Route53, and IAM. The pipeline also includes security scanning with Trivy and TfSec.

## Demo of the Application

[Watch Demo Screen Recording](https://www.loom.com/share/11dce8d46d0949a9ba34c37633aa17df)

This demo shows the Aim web application interface and demonstrates how it tracks machine learning experiments, logs metrics and parameters, and visualizes results through its web-based UI.

## Local Setup

Prerequisites: Python 3.11+.

Run locally:

```bash
pip install aim  
aim up --host 0.0.0.0 --port 8080
```

The Aim UI will be available at http://localhost:8080.

## Project Structure

```
aim-ecs-project/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       ├── destroy.yml
│       └── build.yml
├── aim/
│   ├── aim/
│   ├── docker/
│   │   └── Dockerfile
│   └── main.py
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── modules/
│       ├── vpc/
│       ├── ecs/
│       ├── alb/
│       ├── ecr/
│       ├── route53/
│       └── acm/
└── README.md
```

## Development

Run tests with:

```bash
cd aim
pytest tests/
```

For linting:

```bash
cd infra
terraform fmt -check
tflint

cd aim
ruff check .
```

The CI/CD pipeline automatically runs TfSec for Terraform security scanning and Trivy for Docker image vulnerability scanning.


## Security

The infrastructure follows security best practices:

- Terraform state is stored in an encrypted S3 bucket
- State locking is handled via native S3 locking
- ECS tasks run in private subnets
- Security groups use least privilege access
- All traffic is encrypted with HTTPS/TLS
- GitHub Actions uses OIDC authentication instead of long-lived credentials