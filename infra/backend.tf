terraform {
  backend "s3" {
    bucket = "gatus-tf-bucket"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"
    encrypt        = true
    use_lockfile = true
    
  }
}
