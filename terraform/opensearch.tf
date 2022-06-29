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

resource "aws_opensearch_domain_policy" "first_domain_policy" {
  domain_name = aws_opensearch_domain.first_opensearch.domain_name

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AccessByAdministrator",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/demo/opensearch-admin"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "${var.my_ip}"
          ]
        }
      },
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/first-opensearch/*"
    },
    {
      "Sid": "AccessByReadOnlyUser",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/demo/opensearch-read-only"
        ]
      },
      "Action": [
        "es:ESHttpGet"
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
POLICIES
}
