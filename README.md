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

2. Remotely in ICP

[IBM Cloud Private Cluster](https://www.ibm.com/cloud/private)

Create a Kubernetes cluster in an on-premise datacenter. The community edition (IBM Cloud private-ce) is free of charge.
Follow the instructions [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/installing/install_containers_CE.html) to install IBM Cloud private-ce.

[Helm](https://github.com/kubernetes/helm) (Kubernetes package manager)

Follow the instructions [here](https://github.com/kubernetes/helm/blob/master/docs/install.md) to install it on your platform.
If using IBM Cloud Private version 2.1.0.2 or newer, we recommend you follow these [instructions](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/app_center/create_helm_cli.html) to install helm.

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

### Remotely in ICP

[IBM Cloud Private](https://www.ibm.com/cloud/private)

IBM Private Cloud has all the advantages of public cloud but is dedicated to single organization. You can have your own security requirements and customize the environment as well. Basically it has tight security and gives you more control along with scalability and easy to deploy options. You can run it externally or behind the firewall of your organization.

Basically this is an on-premise platform.

Includes docker container manager
Kubernetes based container orchestrator
Graphical user interface
You can find the detailed installation instructions for IBM Cloud Private [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/installing/install_containers_CE.html)

#### Pushing the image to Private Registry

1. Now run the docker build.

`docker build -t auth:v1.0.0 .`

If it is a success, you will see the below output.

```
Successfully built d884278b44f2
Successfully tagged auth:v1.0.0
```

2. Tag the image to your private registry.

`docker tag auth:v1.0.0 <Your ICP registry>/auth:v1.0.0`

3. Push the image to your private registry.

`docker push <Your ICP registry>/auth:v1.0.0`

You should see something like below.

```
v1.0.0: digest: sha256:0e13f71a1ab34830c895e34c399d4a7d435a34af6a6d347f898213bfa76f33de size: 3873
```

#### Running the application on ICP

1. Your [IBM Cloud Private Cluster](https://www.ibm.com/cloud/private) should be up and running.

2. Log in to the IBM Cloud Private. 

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/icp_dashboard.png">
</p>

3. Go to `admin > Configure Client`.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/client_config.png">
</p>

4. Grab the kubectl configuration commands.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/kube_cmds.png">
</p>

5. Run those commands in your terminal.

6. If successful, you should see something like below.

```
Switched to context "xxx-cluster.icp-context".
```
7. Run the below command.

`helm init --client-only`

You will see the below

```
$HELM_HOME has been configured at /Users/user@ibm.com/.helm.
Not installing Tiller due to 'client-only' flag having been set
Happy Helming!
```

8. Verify the helm version

`helm version --tls`

You will see something like below.

```
Client: &version.Version{SemVer:"v2.7.2+icp", GitCommit:"d41a5c2da480efc555ddca57d3972bcad3351801", GitTreeState:"dirty"}
Server: &version.Version{SemVer:"v2.7.2+icp", GitCommit:"d41a5c2da480efc555ddca57d3972bcad3351801", GitTreeState:"dirty"}
```

9. Before running the helm chart in minikube, access [values.yaml](https://github.com/ibm-cloud-architecture/refarch-cloudnative-micro-inventory/blob/microprofile/catalog/chart/catalog/values.yaml) and replace the repository with the below.

`repository: <Your IBM Cloud Private Docker registry>`

Then run the helm chart.

`helm install --name=auth chart/auth --tls`

You will see message like below.

```
==> v1beta1/Deployment
NAME             DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
auth-deployment  1        1        1           0          1s
```
Please wait till your deployment is ready. To verify run the below command and you should see the availability.

`kubectl get deployments`

You will see something like below.

```
==> v1beta1/Deployment
NAME                               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
auth-deployment                    1         1         1            1           2m
```

10. To test if your application works, follow these steps.

- To get the IP, Run this command.

`kubectl cluster-info`

You will see something like below.

```
Kubernetes master is running at https://172.16.40.4:8001
catalog-ui is running at https://172.16.40.4:8001/api/v1/namespaces/kube-system/services/catalog-ui/proxy
Heapster is running at https://172.16.40.4:8001/api/v1/namespaces/kube-system/services/heapster/proxy
icp-management-ingress is running at https://172.16.40.4:8001/api/v1/namespaces/kube-system/services/icp-management-ingress/proxy
image-manager is running at https://172.16.40.4:8001/api/v1/namespaces/kube-system/services/image-manager/proxy
KubeDNS is running at https://172.16.40.4:8001/api/v1/namespaces/kube-system/services/kube-dns/proxy
platform-ui is running at https://172.16.40.4:8001/api/v1/namespaces/kube-system/services/platform-ui/proxy
```

Grab the Kubernetes master ip and in this case, `<YourClusterIP>` will be `172.16.40.4`.

- To get the port, run this command.

`kubectl get service auth-service`

You will see something like below.

```
NAME              CLUSTER-IP     EXTERNAL-IP   PORT(S)                         AGE
auth-service      10.10.10.170   <nodes>       9080:31481/TCP,9443:32145/TCP   4m
```

You can now do the below to check if your auth service is working properly.

```
curl -k -d "grant_type=password&client_id=bluecomputeweb&client_secret=bluecomputewebs3cret&username=foo&password=bar&scope=blue" https://172.16.40.4:32145/oidc/endpoint/OP/token
```

Then you will see something like below.

<p align="center">
    <img src="https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/static/imgs/accesstoken_minikube.png">
</p>



### References
1. [OpenID Connect Provider](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.wlp.doc/ae/twlp_config_oidc_op.html)
2. [Configuring a Basic User registry](https://www.ibm.com/support/knowledgecenter/en/SS7K4U_liberty/com.ibm.websphere.wlp.zseries.doc/ae/twlp_sec_basic_registry.html)
