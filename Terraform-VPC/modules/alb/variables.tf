variable "sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "subnets" {
  description = "subnets for alb"
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID for ALB"
  type = string
}

variable "instances" {
  description = "Instance ID for Target Group Attachment"
  type = list(string)
}