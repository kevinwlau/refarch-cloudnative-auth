# Deploy the Auth Application on Open Liberty

You can run your Spring Boot applications on Open Liberty. Open Liberty will be the packaged server and the application will run on it instead of the default embedded server. Below are steps to run the Auth application on Open Liberty.

## Table of Contents

+ [Deploy Auth locally](#deploy-auth-locally)
+ [Deploy the Auth Docker Container](#deploy-the-auth-docker-container)
+ [Validate the Auth Service](/README.md#validate-auth-service)

## Deploy Auth locally

In this section you will build and run the Spring Boot application on Open Liberty locally using Maven. Before we show you how to do so, you will need to deploy a Customer Docker container as shown in the [Setup: Deploy Customer Docker Container section](/README.md#setup-deploy-customer-docker-container).

Once Customer is ready, we can run the Spring Boot Auth application locally as follows:

1. Build the application:
```
$ mvn clean install
```

2. You will need to export the same `HS256_KEY` used when deploying Customers, and if you have been following the example, here's the same key for your convenience:

```
$ export HS256_KEY="E6526VJkKYhyTFRFMC0pTECpHcZ7TGcq8pKsVVgz9KtESVpheEO284qKzfzg8HpWNBPeHOxNGlyudUHi6i8tFQJXC8PiI48RUpMh23vPDLGD35pCM0417gf58z5xlmRNii56fwRCmIhhV7hDsm3KO2jRv4EBVz7HrYbzFeqI45CaStkMYNipzSm2duuer7zRdMjEKIdqsby0JfpQpykHmC5L6hxkX0BT7XWqztTr6xHCwqst26O0g8r7bXSYjp4a"
```

3. Run the application on localhost.

```
java \
  -Djwt.sharedSecret=${HS256_KEY} \
  -DcustomerService.url=http://localhost:8082 \
  -Dserver.port=8083 \
  -jar target/micro-auth-0.0.1.jar
```

Once it is deployed, you will see something like below.

```
Auth microservice is ready for business...
[AUDIT   ] CWWKZ0001I: Application thin-micro-auth-0.0.1 started in 13.167 seconds.
[AUDIT   ] CWWKF0012I: The server installed the following features: [servlet-4.0, springBoot-1.5].
[AUDIT   ] CWWKF0011I: The server BoostServer is ready to run a smarter planet.
```

That's it, you have successfully deployed the Auth microservice. To validate the service, have a look at [Validate Auth Service](/README.md#validate-auth-service)

## Deploy the Auth Docker Container

In this section you will run the Spring Boot application on Open Liberty using Docker. Before we show you how to do so, you will need to deploy a Customer Docker container as shown in the [Setup: Deploy Customer Docker Container section](/README.md#setup-deploy-customer-docker-container).

Once it is deployed, we can run the Spring Boot Orders application on Open Liberty docker as follows:

1. Modify your POM file to generate the Docker image. Follow the below steps.
- Open [`pom.xml`](pom.xml)
- Modify the `boost-maven-plugin` as below.

```
            <plugin>
                <groupId>io.openliberty.boost</groupId>
                <artifactId>boost-maven-plugin</artifactId>
                <version>0.1.1</version>
                <executions>
                  <execution>
                    <!-- <phase>package</phase>
                    <goals>
                        <goal>package</goal>
                    </goals> -->
                    <goals>
                      <goal>docker-build</goal>
                    </goals>
                  </execution>
                </executions>
            </plugin>
```

2. You will need to export the same `HS256_KEY` used when deploying Customers, and if you have been following the example, here's the same key for your convenience:

```
$ export HS256_KEY="E6526VJkKYhyTFRFMC0pTECpHcZ7TGcq8pKsVVgz9KtESVpheEO284qKzfzg8HpWNBPeHOxNGlyudUHi6i8tFQJXC8PiI48RUpMh23vPDLGD35pCM0417gf58z5xlmRNii56fwRCmIhhV7hDsm3KO2jRv4EBVz7HrYbzFeqI45CaStkMYNipzSm2duuer7zRdMjEKIdqsby0JfpQpykHmC5L6hxkX0BT7XWqztTr6xHCwqst26O0g8r7bXSYjp4a"
```


3. To deploy the Auth container, run the following commands:

Before building the Docker image, make sure there are no other dockerfiles in your repo. If a dockerfile already exists, please remove it.

```bash
# Build the Docker Image
$ mvn clean install 
```

Once done, a Docker image named `liberty-auth-spring:latest` will be built automatically for you.

Run the Docker container as follows.

```
# Start the Orders Container
$ docker run --name auth \
    -e CUSTOMERSERVICE_URL=http://${CUSTOMER_IP_ADDRESS}:8082 \
    -e HS256_KEY=${HS256_KEY} \
    -p 8083:8083 \
    -d auth
```

That's it, you have successfully deployed the Auth microservice. To validate the service, have a look at [Validate Auth Service](/README.md#validate-auth-service)
