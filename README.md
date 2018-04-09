###### refarch-cloudnative-auth

# Secure REST API with OpenID Connect Provider

*This repository contains the **MicroProfile** implementation of the **Auth Service** which is a part of the 'IBM Cloud Native Reference Architecture' suite, available at https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes*

<p align="center">
  <a href="https://microprofile.io/">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-wfd/blob/microprofile/static/imgs/microprofile_small.png" width="300" height="100">
  </a>
</p>

1. [Introduction](#introduction)
2. [How it works](#how-it-works)
3. [API Endpoints](#api-endpoints)
4. [Implementation](#implementation)
5. [Features and App details](#features)
6. [Building the app](#building-the-app)
7. [Running the app and stopping it](#running-the-app-and-stopping-it)
    1. [Pre-requisites](#pre-requisites)
    2. [Locally in JVM](#locally-in-jvm)
    3. [Locally in Containers](#locally-in-containers)
    4. [Locally in Minikube](#locally-in-minikube)
    5. [Remotely in ICP](#remotely-in-icp)
8. [DevOps Strategy](#devops-strategy)
9. [References](#references)

### Introduction

This project demonstrates how to authenticate the API user using [OpenID Connect](https://www.ibm.com/support/knowledgecenter/en/SSD28V_8.5.5/com.ibm.websphere.wlp.core.doc/ae/cwlp_openid_connect.html) in the BlueCompute reference application. The MicroProfile based Authorization Server is used as an OpenID Connect Provider; the BlueCompute reference application delegates authentication and authorization to this component, which verifies the user credentials. The project contains the following components:

 - MicroProfile based Authorization Server application that handles user authentication and authorization.
 - Uses OpenID Connect 1.0 and acts as a provider to validate login credentials.
 - Return a [mpJwt](https://www.ibm.com/support/knowledgecenter/en/SSAW57_liberty/com.ibm.websphere.liberty.autogen.nd.doc/ae/rwlp_config_mpJwt.html) Bearer token back to caller for identity propagation and authorization.
 
### How it works

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

- GET `/bluecomputeweb/OP/authorize`
- POST `/bluecomputeweb/OP/token`

The BlueCompute reference application supports the following clients and grant types:

- The [BlueCompute Web Application](https://github.com/ibm-cloud-architecture/refarch-cloudnative-bluecompute-web) using client ID `bluecomputeweb` and client secret `bluecomputewebs3cret` supports Password grant type.

The BlueCompute application has one scope, `blue`.

### Implementation

#### [Liberty app accelerator](https://liberty-app-accelerator.wasdev.developer.ibm.com/start/)

For Liberty, there is nice tool called [Liberty Accelerator](https://liberty-app-accelerator.wasdev.developer.ibm.com/start/) that generates a simple project based upon your configuration. Using this, you can build and deploy to Liberty either using the Maven or Gradle build.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/LibertyAcc_Home.png">
</p>

Just check the options of your choice and click Generate project. You can either Download it as a zip or you can create git project.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/LibertyAcc_PrjGen.png">
</p>

Once you are done with this, you will have a sample microprofile based application that you can deploy on Liberty.

Using Liberty Accelerator is your choice. You can also create the entire project manually, but using Liberty Accelerator will make things easier.

### Features

1. OpenID Connect Provider

Configure a Liberty server to act as an OpenID Connect Provider by enabling the openidConnectServer-1.0 feature in Liberty. The ssl-1.0 feature is also required for the openidConnectServer-1.0 feature. This OpenID Connect provider is built on the top OAuth Provider. So, the oauth provider should be configured as well along with the OpenID Connect provider. 

2. Basic User Registry

Liberty Server can be configured with a basic user registry by defining the users and groups information for authentication.

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

### Running the app and stopping it

### Pre-requisites

1. Locally in JVM

To run the Orders microservice locally in JVM, please complete the [Building the app](#building-the-app) section.

### Locally in JVM

1. Make sure you copied your SSL certificate in a file to later move to the rest protected services in the backend.

Since we are using default keystore in our server, we need to get the key from the keystore of the OpenID Provider and put it in the truststore of the backend services that are protected.

Use the below lines to copy the SSL certificate from the Authentication server.

```
cd target/liberty/wlp/usr/servers/defaultServer/resources/security

keytool -exportcert -keystore key.jks -storepass keypass -alias default -file libertyOP.cer
```

When this is done you see something like below.

```
Certificate stored in file <libertyOP.cer>
```

Then get back to the home folder of Auth service as below.

```
cd /Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth
```

2. Start your server.

   `mvn liberty:start-server -DtestServerHttpPort=9085 -DtestServerHttpsPort=9443`

   You will see the below.
   
```
[INFO] Starting server defaultServer.
[INFO] Server defaultServer started with process ID 94296.
[INFO] Waiting up to 30 seconds for server confirmation:  CWWKF0011I to be found in /Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth/target/liberty/wlp/usr/servers/defaultServer/logs/messages.log
[INFO] CWWKM2010I: Searching for CWWKF0011I in /Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth/target/liberty/wlp/usr/servers/defaultServer/logs/messages.log. This search will timeout after 30 seconds.
[INFO] CWWKM2015I: Match number: 1 is [16/3/18 16:41:04:003 CDT] 0000001a com.ibm.ws.kernel.feature.internal.FeatureManager            A CWWKF0011I: The server defaultServer is ready to run a smarter planet..
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 34.004 s
[INFO] Finished at: 2018-03-16T16:41:04-05:00
[INFO] Final Memory: 13M/309M
[INFO] ------------------------------------------------------------------------
```
3. Validate the auth service in the following way.

```
curl -k -d "grant_type=password&client_id=bluecomputeweb&client_secret=bluecomputewebs3cret&username=foo&password=bar&scope=blue" https://localhost:9443/oidc/endpoint/OP/token
```

Then you will see something like below.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/accesstoken.png">
</p>

4. If you are done accessing the application, you can stop your server using the following command.

   `mvn liberty:stop-server -DtestServerHttpPort=9085 -DtestServerHttpsPort=9443`

Once you do this, you see the below messages.

```
[INFO] CWWKM2001I: Invoke command is [/Users/user@ibm.com/BlueCompute/refarch-cloudnative-auth/target/liberty/wlp/bin/server, stop, defaultServer].
[INFO] objc[94536]: Class JavaLaunchHelper is implemented in both /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/bin/java (0x1016294c0) and /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/libinstrument.dylib (0x1017234e0). One of the two will be used. Which one is undefined.
[INFO] Stopping server defaultServer.
[INFO] Server defaultServer stopped.
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2.213 s
[INFO] Finished at: 2018-03-16T16:44:48-05:00
[INFO] Final Memory: 13M/309M
[INFO] ------------------------------------------------------------------------
```

#### Docker file

We are using Docker to containerize the application. With Docker, you can pack, ship, and run applications on a portable, lightweight container that can run anywhere virtually.

```
FROM websphere-liberty:webProfile7
MAINTAINER IBM Java engineering at IBM Cloud
COPY /target/liberty/wlp/usr/servers/defaultServer /config/
# Install required features if not present, install APM Data Collector
RUN installUtility install --acceptLicense defaultServer && installUtility install --acceptLicense apmDataCollector-7.4
RUN /opt/ibm/wlp/usr/extension/liberty_dc/bin/config_liberty_dc.sh -silent /opt/ibm/wlp/usr/extension/liberty_dc/bin/silent_config_liberty_dc.txt
# Upgrade to production license if URL to JAR provided
ARG LICENSE_JAR_URL
RUN \ 
  if [ $LICENSE_JAR_URL ]; then \
    wget $LICENSE_JAR_URL -O /tmp/license.jar \
    && java -jar /tmp/license.jar -acceptLicense /opt/ibm \
    && rm /tmp/license.jar; \
  fi
```

- The `FROM` instruction sets the base image. You're setting the base image to `websphere-liberty:microProfile`.
- The `MAINTAINER` instruction sets the Author field. Here it is `IBM Java engineering at IBM Cloud`.
- The `COPY` instruction copies directories and files from a specified source to a destination in the container file system.
  - You're copying the `/target/liberty/wlp/usr/servers/defaultServer` to the `config` directory in the container.
  - You're replacing the contents of `/opt/ibm/wlp/usr/shared/` with the contents of `target/liberty/wlp/usr/shared`.
- The `RUN` instruction runs the commands.
  - The instruction is a precondition to install all the utilities in the server.xml file. You can use the RUN command to install the utilities on the base image.
- The `CMD` instruction provides defaults for an executing container.

#### Running the application locally in a docker container

1. Build the docker image.

`docker build -t auth:microprofile .`

Once this is done, you will see something similar to the below messages.
```
Successfully built ac9f8efbf322
Successfully tagged auth:microprofile
```
You can see the docker images by using this command.

`docker images`

```
REPOSITORY                                      TAG                 IMAGE ID            CREATED             SIZE
auth                                            microprofile        ac9f8efbf322        5 minutes ago       443MB
```

2. Run the docker image.

`docker run -d -p 9580:9080 -p 7443:9443 --name auth auth:microprofile`

When it is done, you can verify it using the below command.

`docker ps`

You will see something like below.

```
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS              PORTS                                            NAMES
b95229488ab9        auth:microprofile                   "/opt/ibm/docker/doc…"   1 second ago        Up 2 seconds        0.0.0.0:9580->9080/tcp, 0.0.0.0:7443->9443/tcp   auth
8916b347e5dd        catalog:microprofile                "/opt/ibm/wlp/bin/se…"   2 hours ago         Up 2 hours          9443/tcp, 0.0.0.0:9280->9080/tcp                 catalog
7ad59d6b0a59        ibmcase/bluecompute-elasticsearch   "/run.sh"                2 hours ago         Up 2 hours          0.0.0.0:9200->9200/tcp, 9300/tcp                 elasticsearch
f0d52b900623        02a2348107d9                        "/opt/ibm/wlp/bin/se…"   2 days ago          Up 2 days           9443/tcp, 0.0.0.0:9180->9080/tcp                 inventory
736f27b676de        mysql                               "docker-entrypoint.s…"   2 days ago          Up 2 days           0.0.0.0:9041->3306/tcp                           mysql
```

3. Validate the auth service in the following way.

```
curl -k -d "grant_type=password&client_id=bluecomputeweb&client_secret=bluecomputewebs3cret&username=foo&password=bar&scope=blue" https://localhost:7443/oidc/endpoint/OP/token
```

Then you will see something like below.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/accesstoken_docker.png">
</p>

5. Once you are done accessing the application, you can come out of the process. 

6. You can also remove the container if desired. This can be done in the following way.

`docker ps`

```
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                              NAMES
b95229488ab9        auth:microprofile            "/opt/ibm/docker/doc…"   1 second ago        Up 2 seconds        0.0.0.0:9580->9080/tcp, 0.0.0.0:7443->9443/tcp   auth
```

Grab the container id.

- Do `docker stop <CONTAINER ID>`
In this case it will be, `docker stop b95229488ab9`
- Do `docker rm <CONTAINER ID>`
In this case it will be, `docker rm b95229488ab9`


### References
1. [OpenID Connect Provider](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.wlp.doc/ae/twlp_config_oidc_op.html)
2. [Configuring a Basic User registry](https://www.ibm.com/support/knowledgecenter/en/SS7K4U_liberty/com.ibm.websphere.wlp.zseries.doc/ae/twlp_sec_basic_registry.html)
