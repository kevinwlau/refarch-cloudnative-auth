# refarch-cloudnative-micro-auth: Secure REST API with OAuth 2.0 and Authorization Service

## Introduction
This chart will deploy a Spring Boot Application with a Customer database onto a Kubernetes Cluster.

![Application Architecture](https://github.com/fabiogomezdiaz/refarch-cloudnative-auth/raw/spring/static/diagrams/auth.png?raw=true)

Here is an overview of the chart's features:
- Leverage [`Spring Boot`](https://projects.spring.io/spring-boot/) framework to build a Microservices application.
- Spring-based [`Authorization Server`](https://spring.io/projects/spring-security-oauth) application that handles user authentication and authorization.
- Uses [`Spring Feign Client`](https://cloud.spring.io/spring-cloud-netflix/multi/multi_spring-cloud-feign.html) to call Customer Microservice to validate login credentials.
- Return a signed [JWT](https://jwt.io) Bearer token back to caller for identity propagation and authorization
- Uses [`Docker`](https://docs.docker.com/) to package application binary and its dependencies.
- Uses [`Helm`](https://helm.sh/) to package application and Customer deployment configuration and deploy to a [`Kubernetes`](https://kubernetes.io/) cluster. 

## Chart Source
The source for the `Auth` chart can be found at:
* https://github.com/ibm-cloud-architecture/refarch-cloudnative-micro-auth/tree/spring/chart/auth

The source for the `Customer` chart can be found at:
* https://github.com/ibm-cloud-architecture/refarch-cloudnative-micro-customer/tree/spring/chart/customer

## APIs
- GET `/oauth/authorize`
- POST `/oauth/token`

## Deploy Auth Application to Kubernetes Cluster from CLI
To deploy the Auth Chart and its Customer dependency Chart to a Kubernetes cluster using Helm CLI, follow the instructions below:
```bash
# Clone auth repository:
$ git clone http://github.com/refarch-cloudnative-micro-auth.git

# Go to Chart Directory
$ cd refarch-cloudnative-micro-auth/chart/auth

# Download Customer Dependency Chart
$ helm dependency update

# Deploy Auth and Customer to Kubernetes cluster
$ helm upgrade --install auth --set service.type=NodePort .
```