#!/bin/bash

function parse_arguments() {
	#set -x;
	# AUTH_HOST
	if [ -z "${AUTH_HOST}" ]; then
		echo "AUTH_HOST not set. Using parameter \"$1\"";
		AUTH_HOST=$1;
	fi

	if [ -z "${AUTH_HOST}" ]; then
		echo "AUTH_HOST not set. Using default key";
		AUTH_HOST=127.0.0.1;
	fi

	# AUTH_PORT
	if [ -z "${AUTH_PORT}" ]; then
		echo "AUTH_PORT not set. Using parameter \"$2\"";
		AUTH_PORT=$2;
	fi

	if [ -z "${AUTH_PORT}" ]; then
		echo "AUTH_PORT not set. Using default key";
		AUTH_PORT=8083;
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

	#set +x;
}

function obtain_password_token() {
	TOKEN=$(curl -X POST -u bluecomputeweb:bluecomputewebs3cret http://${AUTH_HOST}:${AUTH_PORT}/oauth/token\?grant_type\=password\&username\=${TEST_USER}\&password\=${TEST_PASSWORD}\&scope\=blue | jq -r '.access_token');
	#echo "TOKEN = ${TOKEN}"
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