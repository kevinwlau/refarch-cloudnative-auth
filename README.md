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

- GET `/OP/authorize`
- POST `/OP/token`

The BlueCompute reference application supports the following clients and grant types:

- The [BlueCompute Web Application](https://github.com/ibm-cloud-architecture/refarch-cloudnative-bluecompute-web) using client ID `bluecomputeweb` and client secret `bluecomputewebs3cret` supports Password grant type.

The BlueCompute application has one scope, `blue`.

### Implementation

Configured as a OpenID Connect Provider using WebSphere Liberty.

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

For any of the below methods, the application needs a keystore to be set. In our case, we are using a custom Keystore with self signed certificate. You can follow the instructions for minikube [here](https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/Keystore/README.md#locally-in-minikube) and icp [here](https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/Keystore/README.md#remotely-in-icp).

1. Locally in Minikube

To run the Auth application locally on your laptop on a Kubernetes-based environment such as Minikube (which is meant to be a small development environment) we first need to get few tools installed:

- [Kubectl](https://kubernetes.io/docs/user-guide/kubectl-overview/) (Kubernetes CLI) - Follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to install it on your platform.
- [Helm](https://github.com/kubernetes/helm) (Kubernetes package manager) - Follow the instructions [here](https://github.com/kubernetes/helm/blob/master/docs/install.md) to install it on your platform.

Finally, we must create a Kubernetes Cluster. As already said before, we are going to use Minikube:

- [Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/) - Create a single node virtual cluster on your workstation. Follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-minikube/) to get Minikube installed on your workstation.

We not only recommend to complete the three Minikube installation steps on the link above but also read the [Running Kubernetes Locally via Minikube](https://kubernetes.io/docs/getting-started-guides/minikube/) page for getting more familiar with Minikube. We can learn there interesting things such as reusing our Docker daemon, getting the Minikube's ip or opening the Minikube's dashboard for GUI interaction with out Kubernetes Cluster.

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

### Locally in Containers

To run the application in docker, we first need to define a Docker file.

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

2. Build the docker image.

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

3. Run the docker image.

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

4. Validate the auth service in the following way.

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

### Locally in Minikube

#### Setting up your environment

1. Start your minikube. Run the below command.

`minikube start`

You will see output similar to this.

```
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
```
2. To install Tiller which is a server side component of Helm, initialize helm. Run the below command.

`helm init`

If it is successful, you will see the below output.

```
$HELM_HOME has been configured at /Users/user@ibm.com/.helm.

Tiller (the helm server side component) has been installed into your Kubernetes Cluster.
Happy Helming!
```
3. Check if your tiller is available. Run the below command.

`kubectl get deployment tiller-deploy --namespace kube-system`

If it available, you can see the availability as below.

```
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tiller-deploy   1         1         1            1           1m
```

4. Verify your helm before proceeding like below.

`helm version`

You will see the below output.

```
Client: &version.Version{SemVer:"v2.4.2", GitCommit:"82d8e9498d96535cc6787a6a9194a76161d29b4c", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.5.0", GitCommit:"012cb0ac1a1b2f888144ef5a67b8dab6c2d45be6", GitTreeState:"clean"}
```

#### Running the application on Minikube

1. Make sure your keystore is set before proceeding following the instructions [here](https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/Kube_Jobs/README.md). 

2. Build the docker image.

Before building the docker image, set the docker environment.

- Run the below command.

`minikube docker-env`

You will see the output similar to this.

```
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/user@ibm.com/.minikube/certs"
export DOCKER_API_VERSION="1.23"
# Run this command to configure your shell:
# eval $(minikube docker-env)
```
- For configuring your shell, run the below command.

`eval $(minikube docker-env)`

- Now run the docker build.

`docker build -t auth:v1.0.0 .`

If it is a success, you will see the below output.

```
Successfully built d884278b44f2
Successfully tagged auth:v1.0.0
```
2. Run the helm chart as below.

Before running the helm chart in minikube, access [values.yaml](https://github.com/ibm-cloud-architecture/refarch-cloudnative-micro-inventory/blob/microprofile/inventory/chart/inventory/values.yaml) and replace the repository with the below.

`repository: auth`

Then run the helm chart 

`helm install --name=auth chart/auth`

You will see message like below.

```
==> v1beta1/Deployment
NAME             DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
auth-deployment  1        1        1           0          0s
```
Please wait till your deployment is ready. To verify run the below command and you should see the availability.

`kubectl get deployments`

You will see something like below.

```
==> v1beta1/Deployment
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
auth-deployment   1         1         1            1           16m
```

3. Validate the auth service in the following way.

- To get the IP, Run this command.

`minikube ip`

You will see something like below.

```
192.168.99.100
```

- To get the port, run this command.

`kubectl get service auth-service`

You will see something like below.

```
NAME           CLUSTER-IP     EXTERNAL-IP   PORT(S)                         AGE
auth-service   10.97.21.132   <nodes>       9080:30412/TCP,9443:30160/TCP   19m
```
You can now do the below to check if your auth service is working properly.

```
curl -k -d "grant_type=password&client_id=bluecomputeweb&client_secret=bluecomputewebs3cret&username=foo&password=bar&scope=blue" https://192.168.99.100:30160/oidc/endpoint/OP/token
```

Then you will see something like below.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/accesstoken_minikube.png">
</p>


### References
1. [OpenID Connect Provider](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.wlp.doc/ae/twlp_config_oidc_op.html)
2. [Configuring a Basic User registry](https://www.ibm.com/support/knowledgecenter/en/SS7K4U_liberty/com.ibm.websphere.wlp.zseries.doc/ae/twlp_sec_basic_registry.html)
