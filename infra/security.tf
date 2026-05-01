resource "aws_security_group" "mongo_sg" {
  name        = "${var.project_name}-mongo-sg"
  description = "Security group for MongoDB EC2 instances"
  vpc_id      = module.vpc.vpc_id
  tags        = local.tags

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 의도된 보안 리스크 SSH 포트 전체 공개
  }
  ingress {
    description = "MongoDB from private subnets A"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.private_subnets[0]]
  }

  ingress {
    description = "MongoDB from private subnets B"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.private_subnets[1]]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}