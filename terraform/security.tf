resource "aws_security_group" "web_sg" {
  name        = "cloud-deployment-sg"
  description = "Security group for cloud deployment"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP application traffic
  ingress {
    description = "Flask application"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-deployment-security-group"
  }
}