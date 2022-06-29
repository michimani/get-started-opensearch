resource "aws_iam_role" "opensearch_ro_role" {
  name = "opensearch-read-only"
  path = "/demo/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.iam_user_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "opensearch_admin_role" {
  name = "opensearch-admin"
  path = "/demo/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.iam_user_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
