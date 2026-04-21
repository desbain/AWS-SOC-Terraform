###############################################################################
# ec2/outputs.tf
###############################################################################

output "public_ip" {
  description = "Public IP of SOC-Victim-Host"
  value       = aws_instance.soc_victim.public_ip
}

output "instance_id" {
  description = "Instance ID of SOC-Victim-Host"
  value       = aws_instance.soc_victim.id
}

output "private_ip" {
  description = "Private IP of SOC-Victim-Host"
  value       = aws_instance.soc_victim.private_ip
}