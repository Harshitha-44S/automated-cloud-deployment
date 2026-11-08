output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}