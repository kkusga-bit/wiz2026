data "aws_iam_policy_document" "mongo_ec2_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "mongo_ec2_role" {
  name               = "${var.project_name}-mongo-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.mongo_ec2_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "mongo_admin" {
  role       = aws_iam_role.mongo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # 의도된 보안 리스크 EC2 인스턴스에 관리자 권한 부여 과도 권한
}

resource "aws_iam_instance_profile" "mongo_ec2_profile" {
  name = "${var.project_name}-mongo-ec2-profile"
  role = aws_iam_role.mongo_ec2_role.name
}