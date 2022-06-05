get-started-opensearch
===

Get started OpenSearch.

# Menu

## Start OpensSearch cluster as docker.

Read `docker/README.md`

## Use OpenSearch CLI

### Install

Download from [https://opensearch.org/downloads.html](https://opensearch.org/downloads.html) and install.

```bash
> opensearch-cli --version
opensearch-cli version 1.1.0 darwin/amd64
```

### Create profile

Execute the following command to create a profile When prompted for Username and Password, enter `admin` for both.

```bash
opensearch-cli profile create \
--auth-type basic \
--endpoint https://localhost:9200 \
--name docker-local
```

### Example

Here is an example of executing a `GET _cluster/health` query and outputting the results in yaml format.

```bash
opensearch-cli curl get \
--path '_cluster/health' \
--output-format yaml \
--profile docker-local
```

If you want to omit the `--profile` option, set the environment variable `OPENSEARCH_PROFILE` to the profile name.

```bash
export OPENSEARCH_PROFILE=docker-local
```

# Author

[michimani210](https://twitter.com/michimani210)
