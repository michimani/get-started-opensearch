resource "aws_opensearch_domain" "first_opensearch" {
  domain_name    = "first-opensearch"
  engine_version = "OpenSearch_1.2"

  cluster_config {
    instance_type = "t3.small.search"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}

resource "aws_opensearch_domain_policy" "policy" {
  domain_name     = aws_opensearch_domain.first_opensearch.domain_name
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "${var.my_ip}"
          ]
        }
      },
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/first-opensearch/*"
    }
  ]
}
POLICY
}
