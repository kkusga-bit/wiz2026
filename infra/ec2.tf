data "aws_ami" "ubutu_2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] #의도된 보안 리스크 구버전 Ubuntu 20.04 AMI 사용, 최신 버전으로 업데이트 필요
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
resource "aws_key_pair" "tasky_lab" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "mongo" {
  ami                         = data.aws_ami.ubutu_2004.id
  instance_type               = var.mongo_instance_type
  subnet_id                   = module.vpc.public_subnets[0] #의도된 보안 리스크 Public subnet에 EC2 인스턴스 배치, Private subnet으로 변경 필요
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  key_name                    = aws_key_pair.tasky_lab.key_name
  iam_instance_profile        = aws_iam_instance_profile.mongo_ec2_profile.name
  associate_public_ip_address = true #의도된 보안 리스크 Public IP 할당, Private IP로 변경 필요

  user_data = templatefile("${path.module}/../scripts/mongo-userdata.sh.tpl", {
    mongo_admin_user     = var.mongo_admin_user,
    mongo_admin_password = var.mongo_admin_password,
    mongo_app_user       = var.mongo_app_user,
    mongo_app_password   = var.mongo_app_password,
    bucket_name          = aws_s3_bucket.mongo_backup.bucket
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  tags = merge(local.tags, {
    Name = "${var.project_name}-mongo-ec2"
  })
}