# Run Auth Service locally

## Table of Contents

* [Building the app](#building-the-app)
* [Setting up Cloudant](#setting-up-cloudant)
* [Setting up Zipkin](#setting-up-zipkin) (Optional)
### Running the app and stopping it

# Building the app

To build the application, we used maven build. Maven is a project management tool that is based on the Project Object Model (POM). Typically, people use Maven for project builds, dependencies, and documentation. Maven simplifies the project build. In this task, you use Maven to build the project.

1. Clone this repository.

   `git clone https://github.com/ibm-cloud-architecture/refarch-cloudnative-auth.git`
   
   `cd refarch-cloudnative-auth/`

2. Checkout MicroProfile branch.

   `git checkout microprofile`

3. Create a local instance of a Keystore following the instuctions below.
    https://github.com/ibm-cloud-architecture/refarch-cloudnative-kubernetes/blob/microprofile/Keystore/README.md
    Replace the location in the [server.xml](https://github.com/ibm-cloud-architecture/refarch-cloudnative-auth/blob/microprofile/src/main/liberty/config/server.xml).
 
4. Run this command. This command builds the project and installs it.

   `mvn install`
   
   If this runs successfully, you will be able to see the below messages.

```
[INFO] --- maven-failsafe-plugin:2.18.1:verify (verify-results) @ auth ---
[INFO] Failsafe report directory: /Users/user@ibm.com/Desktop/BlueCompute/refarch-cloudnative-auth/target/test-reports/it
[INFO]
[INFO] --- maven-install-plugin:2.4:install (default-install) @ auth ---
[INFO] Installing /Users/user@ibm.com/Desktop/BlueCompute/refarch-cloudnative-auth/target/auth-1.0-SNAPSHOT.war to /Users/user@ibm.com/.m2/repository/projects/auth/1.0-SNAPSHOT/auth-1.0-SNAPSHOT.war
[INFO] Installing /Users/user@ibm.com/Desktop/BlueCompute/refarch-cloudnative-auth/pom.xml to /Users/user@ibm.com/.m2/repository/projects/auth/1.0-SNAPSHOT/auth-1.0-SNAPSHOT.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 15.788 s
[INFO] Finished at: 2018-07-23T16:38:19-05:00
[INFO] Final Memory: 26M/266M
[INFO] ------------------------------------------------------------------------
```

### Running the app and stopping it

1. Start your server.
```
mvn liberty:start-server -DhttpPort=9080 -DhttpsPort=9443
```
You will see something similar to the below messages.

```
[INFO] Starting server defaultServer.
[INFO] Server defaultServer started with process ID 48582.
[INFO] Waiting up to 30 seconds for server confirmation:  CWWKF0011I to be found in /Users/user@ibm.com/Desktop/BlueCompute/refarch-cloudnative-auth/target/liberty/wlp/usr/servers/defaultServer/logs/messages.log
[INFO] CWWKM2010I: Searching for CWWKF0011I in /Users/user@ibm.com/Desktop/BlueCompute/refarch-cloudnative-auth/target/liberty/wlp/usr/servers/defaultServer/logs/messages.log. This search will timeout after 30 seconds.
[INFO] CWWKM2015I: Match number: 1 is [7/24/18 8:03:43:394 CDT] 0000001a com.ibm.ws.kernel.feature.internal.FeatureManager            A CWWKF0011I: The server defaultServer is ready to run a smarter planet..
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 6.524 s
[INFO] Finished at: 2018-07-24T08:03:43-05:00
[INFO] Final Memory: 12M/309M
[INFO] ------------------------------------------------------------------------
```
2. Validate the auth service. You should get an access token from this call.
Make a post request to https://localhost:9443/oidc/endpoint/OP/token with the following body.
```
grant_type=password&client_id=bluecomputeweb&client_secret=bluecomputewebs3cret&username=user&password=password&scope=openid

```

3. If you are done accessing the application, you can stop your server using the following command.

`mvn liberty:stop-server`

Once you do this, you see the below messages
```
[INFO] Stopping server defaultServer.
[INFO] Server defaultServer stopped.
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.952 s
[INFO] Finished at: 2018-07-24T08:03:53-05:00
[INFO] Final Memory: 11M/309M
[INFO] ------------------------------------------------------------------------
```
