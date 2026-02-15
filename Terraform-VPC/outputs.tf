# Root level outputs - these will be shown after terraform apply

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = module.vpc.subnet_ids
}

output "security_group_id" {
  description = "Security Group ID"
  value       = module.sg.sg_id
}

output "ec2_instance_ids" {
  description = "EC2 Instance IDs"
  value       = module.ec2.instances
}

output "alb_dns_name" {
  description = "ALB DNS Name (to access your instances)"
  value       = try(module.alb.alb_dns_name, "ALB not created yet")
}

output "instances_info" {
  description = "Complete instance information for access"
  value       = "Access your instances at their public IPs shown in AWS console"
}
