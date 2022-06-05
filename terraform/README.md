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
    
## describe domain

```bash
aws opensearch describe-domain \
--domain-name 'first-opensearch'
```

### cluster endpoint

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

## call API

e.g: get cluster health

### by cURL

```bash
curl -X GET "${ENDPOINT}/_cluster/health"
```

### by OpenSearch CLI

1. create profile

  ```bash
  opensearch-cli profile create \
  --auth-type disabled \
  --endpoint "${ENDPOINT}" \
  --name aws-test
  ```
  
2. run

  ```bash
  opensearch-cli curl get \
  --path '_cluster/health' \
  --output-format yaml \
  --profile aws-test
  ```
