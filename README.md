## Cluster Autoscaler

This project utilizes terraform and a Jenkins pipeline to deploy Cluster Autoscaler on AWS EKS cluster. This project will potentially be consolidated with all of GPN's Team-5 products into a single Arche-Type. Cluster Autoscaler is a piece of software that is deployed along side other management applications in the Kuberenetes control plane. The function of Cluster Autoscaler is to scale pods and nodes up or down when pods fail or are rescheduled onto other nodes. Cluster Autoscaler uses leader election to ensure high availability, but scaling is done by a single replica at a time. 

Helm is a very efficient package manager that can be used to deploy applications on Kubernetes clusters. The parameters and specifics of the installation is communicated to Kubernetes using a Helm Chart. Helm charts make package deployments easy, efficient, fast, and simple.

Terraform is an infrastructure provisioning language built in go. Terraform allows repeatable and efficient deployment of infrastructure in a stateful manner. Terraform is integrated very well with AWS and is the single alternative to CloudFormation from AWS.

This project will deploy Cluster Autoscaler, using Helm and Terraform. Below are the prerequisites and requirements needed to stand up the project and run.

## Prerequisites
1. Functional EKS cluster
2. OIDC Provider URL
3. OIDC Provider ARN
4. Permssions for the identity deploying the application to control the cluster
5. OIDC should be connected to the cluster (not just provisioned in the account)

Make sure you have the following installed:

- Make
- Docker
- AWS Credentials
- AWS CLI
- Terraform

## Usage

Make commands are used to orchestrate and organize this project's deployment. The approach employed allows the creation of a central cluster that can used and manage by all the products or launching a standalone cluster to support product development. Run the appropriate commands for development versus contribute to the team's single pipeline. Follow the commands for each product below as listed. For more details, review the commands with the [Makefile](./Makefile).

### Products

#### Central Cluster

To deploy a cluster with to target aws-region, run the following commands as listed either locally or within a pipeline.
> Reference: [Terraform module which creates EKS resources on AWS](https://registry.terraform.io/modules/howdio/eks/aws/latest)

```make
make test PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

Run this command to deploy your changes to the cluster.
> __WARNING:__ This command makes permanent changes to the cluster. PROCEED WITH CAUTION

```make
make deploy PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

To clean-up deployed resources, run:

```make
make teardown PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

#### IAM Authenticator

__TBD__

#### Kube2IAM

* Helm Install - [Chart](https://github.com/jtblin/kube2iam/tree/master/charts/kube2iam)
* Dockerized - [Image](https://hub.docker.com/r/jtblin/kube2iam)

#### Cluster Autoscaler

__TBD__

#### FSx for Windows File Share

__TBD__

## Product Integration

The table below describes the assumption made on each product, top-level input variables and expected output to be consumed by downstream products or within an archetype.
> The information contained within this table would be used to define each product's externalization parameters and integration link with other products.

| Product | Dependencies | Prerequisites | Input Variables | Output Variables | Assumptions |
| ------- | ------------ | ------------- | --------------- | ---------------- | ----------- |
| Central Cluster | Cluster Namespace & Definitions | `docker`, `make`, `awscli`| 1. cluster_name <br> 2. asg_combination | 1. workers_iam_role_arn <br> 2. cluster_name <br> 3. aws_region | None at this point |
| IAM Authenticator | Cluster, IAM Admin Role | `aws-iam-authenticator`, `kubectl` | | | |
| Kube2IAM | Cluster, IAM Worker Roles | `aws-iam-authenticator`, `kubectl`, `helm`| | | |
| CLuster Autoscaler | Cluster, OIDC, IAM Policy for Autoscaler, K8s ServiceAccount | `kubectl`, `helm` | | | |
| FSx for Windows File Server | Cluster, Microsoft Active Directory, Remote Desktop Gateway | `kubectl`, `helm` | | | |
| | | | | | |

## Monitoring and Alerting

### Monitoring

#### Prometheus

> Work-in-Progress

#### Grafana

> Work-in-Progress

#### K8s Dashboard

* Dashboard - [Kubernetes Dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html)

### Alerting and Reporting

* Logging - [Elasticsearch, Fluentd and Kibana (EFK) Logging Stack](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes#:~:text=Fluentd%20is%20a%20popular%20open,will%20be%20indexed%20and%20stored.)
* Fluentd - [Kubernetes Fluentd](https://docs.fluentd.org/v/0.12/articles/kubernetes-fluentd)

## Security Checks

__TBD__

## Development

This development approach follows a a micro-services methodology of utilizing a docker conatiner has its smallest unit of functionality. The project's packages and utilities are pre-packaged and installed within the base image. See the base `Dockerfile` - [Base Dockerfile](/docker/Dockerfile.base) for detials on pre-installed utilities and packages. The base image has been baked and stored with a remote registry and utlized within the Jenkins pipeline to reduced build time during each commits.

To deploy the products cluster, run the following commands to setup your local development environment

### Develop

```make
make develop
```

This command run both a build and exection of the local devleopment docker container.

### Clean-up

Teardown all deploy resources by running:

```make
make teardown
```

## Test

Run the following commands to lint, unit-test and functional test your infrastructure before deploying.

```make
make test PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

### Linting and Validation

```make
make init PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

```make
make plan PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

```make
make validate PRODUCT=cluster AWS_DEFAULT_REGION=<your-target-region>
```

### Functional testing

```make
make compliance
```

### Unit Testing

> The unit testing process for this project is work-in-progress. Frameworks are yet to be aligned with customer's goal.

At minimum, this project would implements [pytest_terraform](https://github.com/cloud-custodian/pytest-terraform) pending customer's decision. This is a pytest plugin that enables executing terraform to provision infrastructure in a unit/functional test as a fixture.

### Compliance Testing

The project uses [terraform-compliance](https://terraform-compliance.com/) test framework to create these policies that will be executed against your terraform plan in a context where both developers teams can understand and apply [Behaviour Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) principles.

### Security Testing

> Security testing will be implemented at mionimum using OPA Policy Agent and Control Access Checker.

## Contributing

_TBD_

## License

Copyright (c) 2021 VerticalRelevance
