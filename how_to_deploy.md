# Deployment Guide

This guide explains how to deploy **Gatus** to **AWS ECS (Fargate)** using the Terraform + GitHub Actions setup in this repo.

> This repo uses **S3 native state locking** (`use_lockfile = true`) → **no DynamoDB**.

---

## Prerequisites

- AWS account with permissions to manage: **ECS, ECR, ALB, ACM, Route 53, S3, IAM**
- A domain you control + a **Route 53 Hosted Zone** for it (e.g. `yassinsuleiman.com`)
- **Docker** (for local builds/tests)
- **Terraform** (required locally only for the bootstrap step)

---

## Repository configuration

### GitHub Actions Secrets

Add this repository secret:

- `AWS_OIDC_ARN` → IAM Role ARN that GitHub Actions assumes via OIDC

### GitHub Actions Variables

Add these repository variables:

- `AWS_REGION` (example: `eu-west-2`)
- `DOMAIN_NAME` (example: `yassinsuleiman.com`)

> **Important:** `AWS_REGION` must match the region you bootstrap into.  
> If not, you’ll hit “repo does not exist” (ECR) or S3 region redirect issues.

---

## Step-by-step

## 1) Bootstrap (one-time, local)

Bootstrap creates:

- the **S3 bucket** used for Terraform remote state
- the **ECR repository** (`gatus-repo`) so CI can push images

Run from your machine:

```bash
cd terraform/modules/bootstrap
terraform init
terraform apply
```

When prompted, enter your region (example):

```text
var.aws_region
  AWS Region in which your infrastructure will be deployed

  Enter a value: eu-west-2
```

After `apply`, note the outputs:

- `state_bucket`
- `repo_url`
- `region`

---

## 2) Wire the backend (remote state)

Now that the bucket exists, configure the **root Terraform backend** to use it.

Update `terraform/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "YOUR_BOOTSTRAP_BUCKET_NAME"
    key          = "terraform.tfstate"
    region       = "YOUR_REGION"
    encrypt      = true
    use_lockfile = true
  }
}
```

Then reinitialize Terraform:

```bash
cd terraform
terraform init -reconfigure
```

This prevents:

- “backend bucket doesn’t exist yet”
- S3 `PermanentRedirect 301` (region mismatch)

---

## 3) Build & push the Docker image (CI)

Run the **Build & Push** GitHub Actions workflow.

At the end you should have a **real image reference** (don’t use `latest`), e.g.:

- `784607970889.dkr.ecr.eu-west-2.amazonaws.com/gatus-repo:<git_sha>`
- or `...@sha256:<digest>`

If you get:

> `The repository with name 'gatus-repo' does not exist`

Then either:

- you didn’t run bootstrap yet, **or**
- your workflow region (`AWS_REGION`) doesn’t match where bootstrap created the repo.

---

## 4) Update `terraform.tfvars` (set your image + domain)

Copy the example file and fill in your values:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Update `terraform/terraform.tfvars` (minimum required fields shown here):

```hcl
# Region
aws_region = "eu-west-2"

# ECS
app_count = 2
app_port  = 8080

# Use the exact image that CI pushed (tag or digest). Do NOT use "latest".
app_image = "<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/gatus-repo:<IMAGE_TAG_OR_SHA>"

# Networking
my_vpc_cidr = "10.10.0.0/16"
az_count    = 2

# Health checks
health_check_path = "/health"

# DNS / TLS
validation_method = "DNS"  # recommended
domain_name       = "yassinsuleiman.com"
subdomain         = "tm"
```

---

## 5) Deploy (CD)

Run the **Terraform Deploy** workflow.

When it finishes, your app should be reachable at:

`https://<subdomain>.<domain_name>`

Example:

`https://tm.yassinsuleiman.com`

---

## Destroy (optional)

Use the **Terraform Destroy** workflow to tear everything down.

### ECR note

If your destroy deletes the ECR repository, deletion can fail if images still exist.

You have three clean options:

1) **Keep ECR protected** (recommended): `prevent_destroy = true`
2) Use `force_delete = true` on the ECR repository (not recommended for “prod-like”)
3) Delete images first, then destroy

---

## Common errors

- **Build & Push fails: “repo does not exist”**  
  Bootstrap wasn’t applied, or `AWS_REGION` doesn’t match bootstrap region.

- **S3 redirect / region mismatch (301 PermanentRedirect)**  
  Your backend `region` doesn’t match the bucket’s region. Fix `terraform/backend.tf`, then run `terraform init -reconfigure`.

- **Backend bucket missing**  
  The backend can’t create its own bucket. Run bootstrap first, then wire the backend to the created bucket.
