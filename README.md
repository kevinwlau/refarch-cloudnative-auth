###### refarch-cloudnative-auth

# Secure REST API with OpenID Connect Provider

*This repository contains the **MicroProfile** implementation of the **Auth Service** which is a part of the 'IBM Cloud Native Reference Architecture' suite, available at https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes*

<p align="center">
  <a href="https://microprofile.io/">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-wfd/blob/microprofile/static/imgs/microprofile_small.png" width="300" height="100">
  </a>
</p>

* [Introduction](#introduction)
* [How it works](#how-it-works)
* [API Endpoints](#api-endpoints)
* [Implementation](#implementation)
    + [Microprofile](#microprofile)
* [Features](#features)
* [Deploying the App](#deploying-the-app)
    + [IBM Cloud Private](#ibm-cloud-private)
    + [Minikube](#minikube)
    + [Run Auth Service locally](#run-auth-service-locally)
* [References](#references)

### Introduction

This project demonstrates how to authenticate the API user using [OpenID Connect](https://www.ibm.com/support/knowledgecenter/en/SSD28V_8.5.5/com.ibm.websphere.wlp.core.doc/ae/cwlp_openid_connect.html) in the BlueCompute reference application. The MicroProfile based Authorization Server is used as an OpenID Connect Provider; the BlueCompute reference application delegates authentication and authorization to this component, which verifies the user credentials. The project contains the following components:

 - MicroProfile based Authorization Server application that handles user authentication and authorization.
 - Uses OpenID Connect 1.0 and acts as a provider to validate login credentials.
 - Return a [mpJwt](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/com.ibm.websphere.liberty.autogen.nd.doc/ae/rwlp_config_mpJwt.html) Bearer token back to caller for identity propagation and authorization.
 
### How it works

The Auth Microservice serves 'IBM Cloud Native Reference Architecture' suite, available at https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes, Microservice-based reference application.

#### Interaction with OpenID Connect Provider

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/auth_customer_micro.png">
</p>
 
- When username/password is passed in, the Authorization microservice validates the credentials based on the details configured in the basic registry.  

#### Interaction with Resource Server API

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/spring_auth.png">
</p>

- When a client wishes to acquire an access token to call a protected API, it calls the OpenID Connect Provider (Authorization microservice) token endpoint with the username/password of the user and requests a token with scope `blue`.
- Authorization microservice will perform the validation.
- If the username/password are valid, a mpJWT token is returned with an `access token` included in it.
- The client uses the `access token` in the `Authorization` header as a bearer token to call other Resource Servers that have the protected API (such as the [Orders microservice](https://github.com/ibm-cloud-architecture/refarch-cloudnative-micro-orders)).
- The service implementing the REST API verifies that the `access token` from mpJWT is valid, and then extracts the required claims from the mpJWT to identify the caller.
- The mpJWT is encoded with scope `blue` and the the expiry time in `expires_in`; once the token is generated there is no additional interaction between the Resource Server and the Auth server.

### API Endpoints

Following the [OpenID Connect endpoint URLs](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_8.5.5/com.ibm.websphere.wlp.doc/ae/rwlp_oidc_endpoint_urls.html), the Authorization server exposes both an authorization URI and a token URI.

```
GET /OP/authorize
POST /OP/token
```

The BlueCompute reference application supports the following clients and grant types:

- The [BlueCompute Web Application](https://github.com/ibm-cloud-architecture/refarch-cloudnative-bluecompute-web) using client ID `bluecomputeweb` and client secret `bluecomputewebs3cret` supports Password grant type.

The BlueCompute application has three scopes `openid`, `admin`, and  `blue`.

### Implementation

### [MicroProfile](https://microprofile.io/)

MicroProfile is an open platform that optimizes the Enterprise Java for microservices architecture. In this application, we are using [**MicroProfile 1.3**](https://github.com/eclipse/microprofile-bom). This includes

- MicroProfile 1.2 ([MicroProfile Fault Tolerance 1.0](https://github.com/eclipse/microprofile-fault-tolerance), [MicroProfile Health Check 1.0](https://github.com/eclipse/microprofile-health), [MicroProfile JWT Authentication 1.0](https://github.com/eclipse/microprofile-jwt-auth)).

You can make use of this feature by including this dependency in Maven.

```
<dependency>
    <groupId>org.eclipse.microprofile</groupId>
    <artifactId>microprofile</artifactId>
    <version>1.3</version>
    <scope>provided</scope>
    <type>pom</type>
</dependency>
```


You should also include a feature in [server.xml](https://github.com/ibm-cloud-architecture/refarch-cloudnative-auth/blob/microprofile/src/main/liberty/config/server.xml).

```
<server description="Sample Liberty server">

  <featureManager>
      <feature>microprofile-1.3</feature>
  </featureManager>

  <httpEndpoint httpPort="${default.http.port}" httpsPort="${default.https.port}"
      id="defaultHttpEndpoint" host="*" />

</server>
```
### Features

1. OpenID Connect Provider - Configure a Liberty server to act as an OpenID Connect Provider by enabling the openidConnectServer-1.0 feature in Liberty. The ssl-1.0 feature is also required for the openidConnectServer-1.0 feature. This OpenID Connect provider is built on the top of OAuth Provider. So, the oauth provider should be configured as well along with the OpenID Connect provider.

2. Basic User Registry - Liberty Server can be configured with a basic user registry by defining the users and groups information for authentication.

3. [MicroProfile Health Check](https://github.com/eclipse/microprofile-health) - This feature helps us to determine the status of the service as well as its availability. This helps us to know if the service is healthy. If not, we can know the reasons behind the termination or shutdown.

In our sample application, we injected this `/health` endpoint in our liveness probes.

### Building the app

To build the application, we used maven build. Maven is a project management tool that is based on the Project Object Model (POM). Typically, people use Maven for project builds, dependencies, and documentation. Maven simplifies the project build. In this task, you use Maven to build the project.

1. Clone this repository.

   `git clone https://github.com/ibm-cloud-architecture/refarch-cloudnative-auth.git`
   
2. `cd refarch-cloudnative-auth/`

3. Checkout MicroProfile branch.

   `git checkout microprofile`

4. Run this command. This command builds the project and installs it.

   `mvn install`
   
   If this runs successfully, you will be able to see the below messages.
   
```
[INFO] --- maven-failsafe-plugin:2.18.1:verify (verify-results) @ Auth ---
[INFO] Failsafe report directory: /Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth/target/test-reports/it
[INFO]
[INFO] --- maven-install-plugin:2.4:install (default-install) @ Auth ---
[INFO] Installing /Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth/target/Auth-1.0-SNAPSHOT.war to /Users/user@ibm.com/.m2/repository/projects/Auth/1.0-SNAPSHOT/Auth-1.0-SNAPSHOT.war
[INFO] Installing /Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth/pom.xml to /Users/user@ibm.com/.m2/repository/projects/Auth/1.0-SNAPSHOT/Auth-1.0-SNAPSHOT.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 58.099 s
[INFO] Finished at: 2018-03-16T16:33:45-05:00
[INFO] Final Memory: 21M/308M
[INFO] ------------------------------------------------------------------------
```

## Deploying the App

To build and run the entire BlueCompute demo application, each MicroService must be spun up together. This is due to how we
set up our Helm charts structure and how we dynamically produce our endpoints and URLs.  

Further instructions are provided [here](https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/tree/microprofile).

### IBM Cloud Private

To deploy it on IBM Cloud Private, please follow the instructions provided [here](https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/tree/microprofile#remotely-on-ibm-cloud-private).

### Minikube

To deploy it on Minikube, please follow the instructions provided [here](https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/tree/microprofile#locally-in-minikube).

### Run The Auth Service locally
To deploy the app locally and test the individual service, please follow the instructions provided
[here](building-locally.md)
## References

1. [Microprofile](https://microprofile.io/)
2. [MicroProfile Health Checks on Liberty](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_microprofile_healthcheck.html)
