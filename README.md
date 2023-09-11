# Kibana Docker Container Image

[![Build Status](https://github.com/wodby/kibana/workflows/Build%20docker%20image/badge.svg)](https://github.com/wodby/kibana/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/kibana.svg)](https://hub.docker.com/r/wodby/kibana)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/kibana.svg)](https://hub.docker.com/r/wodby/kibana)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/kibana.svg)](https://microbadger.com/images/wodby/kibana)

## Docker Images

❗For better reliability we release images with stability tags (`wodby/kibana:6-X.X.X`) which correspond to [git tags](https://github.com/wodby/kibana/releases). We strongly recommend using images only with stability tags. 

- All images based on Alpine Linux
- Base image: [node](https://hub.docker.com/_/node)
- [GitHub actions builds](https://github.com/wodby/kibana/actions) 
- [Docker Hub](https://hub.docker.com/r/wodby/kibana)

Supported tags and respective `Dockerfile` links:

- `7.17`, `7`, `latest` [_(Dockerfile)_](https://github.com/wodby/kibana/tree/master/Dockerfile)
- `6.8`, `6` [_(Dockerfile)_](https://github.com/wodby/kibana/tree/master/Dockerfile)

## Environment Variables

| Variable                     | Default Value               | Description |
| ---------------------------- | --------------------------- | ----------- |
| `KIBANA_SERVER_NAME`         | `kibana`                    |             |
| `KIBANA_SERVER_HOST`         | `0`                         |             |
| `KIBANA_ELASTICSEARCH_HOSTS` | `http://elasticsearch:9200` |             |

## Orchestration Actions

Usage:
```
make COMMAND [params ...]
 
commands:
    check-ready [host max_try wait_seconds delay_seconds]
 
default params values:
    host localhost
    max_try 1
    wait_seconds 1
    delay_seconds 0
```

## Deployment

Deploy Kibana with Elasticsearch to your own server via [![Wodby](https://www.google.com/s2/favicons?domain=wodby.com) Wodby](https://wodby.com/stacks/elasticsearch).

## Upgrading

To upgrade the underlying version of Opensearch, edit `version` and `tags` in `.github/workflows/workflow.yml`:

```
     - uses: actions/checkout@v2
     - uses: ./.github/actions
       with:
        version: '1.3.12'
        tags: 1.3.12,1.3,1,latest
```

_**Attention:** you need to build the related version of `opensearch` before upgrading `opensearch-dashboards`._

To finalize the release, add an increasing stability tag:

```
git commit -m "Upgrade Opensearch Dashboards to 1.3.12" .
git tag -m "Upgrade Opensearch Dashboards to 1.3.12" 1.0.3
git push && git push --tags

```

The resulting image will be available as `ghcr.io/ramsalt/opensearch-dashboards:1.3.12-1.0.3`
