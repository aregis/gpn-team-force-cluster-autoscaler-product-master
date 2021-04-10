# syntax=docker/dockerfile:1.0.0-experimental

FROM python:alpine as base
RUN apk update && \
  apk add \
  libxml2-dev \
  libxslt-dev \
  openssl-dev \
  openssh-client \
  openssl \
  git \
  gcc \
  glib-dev \
  libc-dev \
  curl \
  make \
  bash

# Install terraform
RUN wget https://releases.hashicorp.com/terraform/0.14.8/terraform_0.14.8_linux_amd64.zip
RUN unzip terraform_0.14.8_linux_amd64.zip
RUN mv terraform /usr/local/bin/
RUN terraform --version


### production
FROM base as production
ENV AWS_DEFAULT_REGION=us-west-2
ENV AWS_DEFAULT_PARTITION=aws
COPY . /gpn-team-force-demo-eks-cluster
CMD ["make", "deploy"]

## dependencies
FROM base as dependencies
WORKDIR /gpn-team-force-demo-eks-cluster
COPY README.md .

### test
FROM dependencies as test
COPY . /gpn-team-force-demo-eks-cluster
CMD ["make", "test"]
