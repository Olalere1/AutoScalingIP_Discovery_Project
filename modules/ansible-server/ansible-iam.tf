# IAM User
resource "aws_iam_user" "ansible-user" {
  name = "ansible_user"
}

# IAM Access Key
resource "aws_iam_access_key" "ansible-user-key" {
  user = aws_iam_user.ansible-user.name
}
#IAM Group
resource "aws_iam_group" "ansible-group" {
  name = "ansible_group"
}

# ansible user to ansible group
resource "aws_iam_user_group_membership" "ansible_group_membership" {
  user   = aws_iam_user.ansible-user.name
  groups = [aws_iam_group.ansible-group.name]
}

resource "aws_iam_group_policy_attachment" "ansible_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  group      = aws_iam_group.ansible-group.name
}