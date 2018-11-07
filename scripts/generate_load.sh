#!/bin/bash
HOST="localhost";
PORT="8083";
URL="http://${HOST}:${PORT}";
DEPLOYMENT="auth-auth";
SERVICE_PATH="oauth/token";

TEST_USER=user;
TEST_PASSWORD=passw0rd;

# trap ctrl-c and call ctrl_c() to stop port forwarding
trap ctrl_c INT

function ctrl_c() {
	echo "** Trapped CTRL-C... Killing Port Forwarding and Stopping Load";
	killall kubectl;
	exit 0;
}

function start_port_forwarding() {
	echo "Forwarding service port ${PORT}";
	kubectl port-forward deployment/${DEPLOYMENT} ${PORT}:${PORT} --pod-running-timeout=1h &
	echo "Sleeping for 3 seconds while connection is established...";
	sleep 3;
}

# Port Forwarding
start_port_forwarding

# Load Generation
echo "Generating load..."

while true; do
	curl -s -X POST -u bluecomputeweb:bluecomputewebs3cret \
		${URL}/${SERVICE_PATH}\?grant_type\=password\&username\=${TEST_USER}\&password\=${TEST_PASSWORD}\&scope\=blue > /dev/null;
	sleep 0.2;
done