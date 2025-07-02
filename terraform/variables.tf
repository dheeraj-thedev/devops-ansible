# This file defines variables we can reuse
variable "aws_region" {
  description = "AWS region for resources"
  default     = "us-west-2"
}
 
variable "ami_id" {
  description = "Ubuntu AMI ID"
  default     = "ami-05f991c49d264708f"  # Ubuntu 20.04 LTS 0f918f7e67a3323f0
}
 
variable "key_name" {
  description = "AWS key pair name"
  default     = "devops-key"  # You'll create this
}
 
variable "project_name" {
  description = "Project name for tagging"
  default     = "devops-ecommerce"
}