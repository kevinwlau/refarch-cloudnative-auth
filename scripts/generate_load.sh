#!/bin/bash
URL="$1";
SERVICE_PATH="oauth/token";

TEST_USER=user;
TEST_PASSWORD=passw0rd;

if [ -z "$URL" ]; then
	URL="http://localhost:8083"
	echo "No URL provided! Using ${URL}"
fi

# Load Generation
echo "Generating load on ${URL}/${SERVICE_PATH}"

while true; do
	curl -s -X POST -u bluecomputeweb:bluecomputewebs3cret \
		${URL}/${SERVICE_PATH}\?grant_type\=password\&username\=${TEST_USER}\&password\=${TEST_PASSWORD}\&scope\=blue > /dev/null;
	echo -n .;
	sleep 0.2;
done