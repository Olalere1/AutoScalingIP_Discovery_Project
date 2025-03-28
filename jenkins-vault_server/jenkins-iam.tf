data "aws_iam_policy_document" "jenkins-ec2-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins-ec2-role" {
  name               = "jenkins-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.jenkins-ec2-policy.json
}

resource "aws_iam_role_policy_attachment" "jenkins-ec2-role-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.jenkins-ec2-role.name
}

resource "aws_iam_instance_profile" "jenkins-role" {
  name = "jenkins-profile-2"
  role = aws_iam_role.jenkins-ec2-role.name
}