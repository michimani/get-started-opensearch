Manage OpenSearch cluster in Amazon OpenSearch Service using terraform.
===

- Terraform: `v1.2.2`
- terraform-provider-aws: `v4.17.1`
- AWS CLI: `v1.27.2`, `v2.7.6`

## Preparing

1. create `main.tf` and `variables.tf`

    ```bash
    cp main.tf.sample main.tf && cp variables.tf.sample variables.tf
    ```
    
    Then, replace each value to your own.  
    Check the value of `my_ip` by executing the following command, for example.
    
    ```bash
    curl -X GET 'https://checkip.amazonaws.com/'
    ```
    
    And, `iam_user_arn` should be the ARN of the IAM User to switch to the IAM Role you will create by this Terraform project. The `sts:AssumeRole` action for any IAM Role must be allowed for this IAM User.

1. run `terraform init`    

    ```bash
    terraform init
    ```
    
## Plan, apply
    
1. plan

    ```bash
    terraform plan
    ```

1. apply

    ```bash
    terraform apply
    ```
    
## Describe domain

```bash
aws opensearch describe-domain \
--domain-name 'first-opensearch'
```

### Get cluster endpoint

```bash
ENDPOINT=$(
  aws opensearch describe-domain \
  --domain-name 'first-opensearch' \
  --query 'DomainStatus.join(``,[`https://`,Endpoint])' \
  --output text
) && echo "${ENDPOINT}"
```

### OpenSearch Dashboard URL

```bash
DASHBOARD=$(
  aws opensearch describe-domain \
  --domain-name 'first-opensearch' \
  --query 'DomainStatus.join(``,[`https://`,Endpoint,`/_dashboards`])' \
  --output text
) && echo "${DASHBOARD}"
```

## Calling API by OpenSearch CLI

First, create profile of OpenSearch CLI that uses AWS IAM as authentication.

```bash
opensearch-cli profile create \
--auth-type aws-iam \
--endpoint "${ENDPOINT}" \
--name env-role
```

```bash
AWS profile name (leave blank if you want to provide credentials using environment variables): # Enter
AWS service name where your cluster is deployed (for Amazon Elasticsearch Service, use 'es'. For EC2, use 'ec2'): # es
```

In addition, create an anonymous profile to ensure that it cannot be accessed by profiles that have not been authenticated by IAM Role.

```bash
opensearch-cli profile create \
--auth-type disabled \
--endpoint "${ENDPOINT}" \
--name anonymous-for-fos
```

```bash
$ opensearch-cli curl get \
--path '_cluster/health' \
--output-format yaml \
--profile anonymous-for-fos

{
  "Message": "User: anonymous is not authorized to perform: es:ESHttpGet because no resource-based policy allows the es:ESHttpGet action"
}
```

```bash
$ opensearch-cli curl put \
--path 'demoindex' \
--profile anonymous-for-fos

{
  "Message": "User: anonymous is not authorized to perform: es:ESHttpPut because no resource-based policy allows the es:ESHttpPut action"
}
```

### Execute on a read-only

1. Switch to read only role

    ```bash
    SWITCH_CMD=$( \
      aws sts assume-role \
      --role-arn $(aws iam list-roles \
      --path-prefix '/demo' \
      --query 'Roles[?contains(to_string(RoleName), `opensearch-read-only`)].Arn' \
      --output text) \
      --role-session-name 'opensearch-read-only' \
      --query 'Credentials.join(``,[`export AWS_ACCESS_KEY_ID=\"`,AccessKeyId,`\" AWS_SECRET_ACCESS_KEY=\"`,SecretAccessKey,`\" AWS_SESSION_TOKEN=\"`,SessionToken,`\"`])' \
      --output text) \
    && eval ${SWITCH_CMD} \
    && aws sts get-caller-identity
    ```

1. Run get action

    ```bash
    opensearch-cli curl get \
    --path '_cluster/health' \
    --output-format yaml \
    --profile env-role
    ```

1. Run put action (will be failed)

    ```bash
    opensearch-cli curl put \
    --path 'demoindex' \
    --profile env-role
    ```
    
    output
    
    ```json
    {
      "Message": "User: arn:aws:sts::000000000000:assumed-role/opensearch-read-only/opensearch-read-only is not authorized to perform: es:ESHttpPut because no identity-based policy allows the es:ESHttpPut action"
    }
    ```

1. Exit from a switched roll.

    ```bash
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    ```

### Execute on an Administrator

1. Switch to read only role

    ```bash
    SWITCH_CMD=$( \
      aws sts assume-role \
      --role-arn $(aws iam list-roles \
      --path-prefix '/demo' \
      --query 'Roles[?contains(to_string(RoleName), `opensearch-admin`)].Arn' \
      --output text) \
      --role-session-name 'opensearch-admin' \
      --query 'Credentials.join(``,[`export AWS_ACCESS_KEY_ID=\"`,AccessKeyId,`\" AWS_SECRET_ACCESS_KEY=\"`,SecretAccessKey,`\" AWS_SESSION_TOKEN=\"`,SessionToken,`\"`])' \
      --output text) \
    && eval ${SWITCH_CMD} \
    && aws sts get-caller-identity
    ```

1. Run get action

    ```bash
    opensearch-cli curl get \
    --path '_cluster/health' \
    --output-format yaml \
    --profile env-role
    ```

1. Run put action (will be succeeded)

    ```bash
    opensearch-cli curl put \
    --path 'demoindex' \
    --profile env-role
    ```
    
        output
    
    ```json
    {"acknowledged":true,"shards_acknowledged":true,"index":"demoindex"}
    ```
    
1. Run delete action

    ```bash
    opensearch-cli curl delete \
    --path 'demoindex' \
    --profile env-role
    ```
    
    output
    
    ```json
    {"acknowledged":true}
    ```

1. Exit from a switched roll.

    ```bash
    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
    ```