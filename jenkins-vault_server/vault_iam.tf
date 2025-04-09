# Asymmetric KMS key for encryption
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault_iam_policy" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = [aws_kms_key.vault.arn]
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]
  }
}

resource "aws_iam_role" "vault_kms_unseal" {
  name               = "vault_kms_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "vault_kms_unseal" {
  name   = "vault_kms"
  role   = aws_iam_role.vault_kms_unseal.id
  policy = data.aws_iam_policy_document.vault_iam_policy.json
}

resource "aws_iam_instance_profile" "vault_kms_profile" {
  name = "vault_kms_unseal-3"
  role = aws_iam_role.vault_kms_unseal.name

}



