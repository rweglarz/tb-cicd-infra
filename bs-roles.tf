variable "MasterS3Bucket" {}

resource "aws_iam_role" "FirewallBootstrapRole2Tier" {
  name = "FirewallBootstrapRole2Tier"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "FirewallBootstrapRolePolicy2Tier" {
  name = "FirewallBootstrapRolePolicy2Tier"
  role = "${aws_iam_role.FirewallBootstrapRole2Tier.id}"

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.MasterS3Bucket}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.MasterS3Bucket}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "FirewallBootstrapInstanceProfile2Tier" {
  name = "FirewallBootstrapInstanceProfile2Tier"
  role = "${aws_iam_role.FirewallBootstrapRole2Tier.name}"
  path = "/"
}
