#!/bin/bash

function parse_arguments() {
	# MICROSERVICE_HOST
	if [ -z "${MICROSERVICE_HOST}" ]; then
		echo "MICROSERVICE_HOST not set. Using parameter \"$1\"";
		MICROSERVICE_HOST=$1;
	fi

	if [ -z "${MICROSERVICE_HOST}" ]; then
		echo "MICROSERVICE_HOST not set. Using default key";
		MICROSERVICE_HOST=127.0.0.1;
	fi

	# MICROSERVICE_PORT
	if [ -z "${MICROSERVICE_PORT}" ]; then
		echo "MICROSERVICE_PORT not set. Using parameter \"$2\"";
		MICROSERVICE_PORT=$2;
	fi

	if [ -z "${MICROSERVICE_PORT}" ]; then
		echo "MICROSERVICE_PORT not set. Using default key";
		MICROSERVICE_PORT=8083;
	fi

	# TEST_USER
	if [ -z "${TEST_USER}" ]; then
		echo "TEST_USER not set. Using parameter \"$4\"";
		TEST_USER=$3;
	fi

	if [ -z "${TEST_USER}" ]; then
		echo "TEST_USER not set. Using default key";
		TEST_USER=user;
	fi

	# TEST_PASSWORD
	if [ -z "${TEST_PASSWORD}" ]; then
		echo "TEST_PASSWORD not set. Using parameter \"$5\"";
		TEST_PASSWORD=$4;
	fi

	if [ -z "${TEST_PASSWORD}" ]; then
		echo "TEST_PASSWORD not set. Using default key";
		TEST_PASSWORD=passw0rd;
	fi

	echo "Using http://${MICROSERVICE_HOST}:${MICROSERVICE_PORT}"
}

function obtain_password_token() {
	TOKEN=$(curl -X POST -u bluecomputeweb:bluecomputewebs3cret http://${MICROSERVICE_HOST}:${MICROSERVICE_PORT}/oauth/token\?grant_type\=password\&username\=${TEST_USER}\&password\=${TEST_PASSWORD}\&scope\=blue | jq -r '.access_token');
	echo "TOKEN = ${TOKEN}"

	# Check that token was returned
	if [ -n "${TOKEN}" ] && [ "${TOKEN}" != "null" ]; then
    	echo "obtain_password_token: ✅";
    else
		printf "obtain_password_token: ❌ \n${CURL}\n";
        exit 1;
    fi
}

# Setup
parse_arguments $1 $2 $3 $4

# API Tests
echo "Starting Tests"
obtain_password_token