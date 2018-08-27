#!/bin/bash

HS256_KEY=$1
COUCHDB_USER=$2
COUCHDB_PASSWORD=$3
TEST_USER=$4
TEST_PASSWORD=$5

function create_jwt() {
	# Secret Key
	secret=${HS256_KEY};
	# JWT Header
	jwt1=$(echo -n '{"alg":"HS256","typ":"JWT"}' | openssl enc -base64);
	# JWT Payload
	jwt2=$(echo -n "{\"scope\":[\"admin\"],\"user_name\":\"${TEST_USER}\"}" | openssl enc -base64);
	# JWT Signature: Header and Payload
	jwt3=$(echo -n "${jwt1}.${jwt2}" | tr '+\/' '-_' | tr -d '=' | tr -d '\r\n');
	# JWT Signature: Create signed hash with secret key
	jwt4=$(echo -n "${jwt3}" | openssl dgst -binary -sha256 -hmac "${secret}" | openssl enc -base64 | tr '+\/' '-_' | tr -d '=' | tr -d '\r\n');
	# Complete JWT
	jwt=$(echo -n "${jwt3}.${jwt4}");

	#echo $jwt_blue
}

function create_user() {
	docker ps
	CURL=$(curl --write-out %{http_code} --silent --output /dev/null --max-time 5 -X POST "http://localhost:8081/micro/customer" -H "Content-type: application/json" -H "Authorization: Bearer ${jwt}" -d "{\"username\": \"${TEST_USER}\", \"password\": \"${TEST_PASSWORD}\", \"firstName\": \"user\", \"lastName\": \"name\", \"email\": \"user@name.com\"}");

	# Check for 201 Status Code
	if [ "$CURL" != "201" ]; then
		printf "create_user: ❌ \n${CURL}\n";
        exit 1;
    else 
    	echo "create_user: ✅";
    fi
}


# Start couchdb container
echo "Starting CouchDB container"
docker run --name couchdb -p 5984:5984 -e COUCHDB_USER=${COUCHDB_USER} -e COUCHDB_PASSWORD=${COUCHDB_PASSWORD} -d couchdb:2.1.2
# Wait for CouchDB to Start
echo "Waiting 20 seconds for CouchDB to start"
sleep 20
# Test CouchDB
echo "Testing CouchDB container"
curl http://127.0.0.1:5984
# Getting CouchDB Container IP Address
echo "Getting CouchDB container IP Address"
COUCHDB_IP=$(docker inspect couchdb | jq -r '.[0].NetworkSettings.IPAddress')

# Start Customer Container and Connect to local MySQL Service
echo "Starting Customer container"
COUCHDB_URI="http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${COUCHDB_IP}:5984"
echo "COUCHDB_URI=http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${COUCHDB_IP}:5984"
docker run --name customer -d -p 8081:8080 -e HS256_KEY=${HS256_KEY} -e COUCHDB_URI="http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@${COUCHDB_IP}:5984" ibmcase/bluecompute-customer:0.5.0
# Wait for the Customer container to start accepting connections
echo "Waiting 25 seconds for Customer to start"
sleep 25
# Check that the Customer container is running
docker ps
# Check logs to see if it started properly
docker logs customer

# Create JWT
create_jwt
# Create User
create_user