#!/bin/bash
source scripts/max_heap.sh

#set -x;
# Set Max Heap
export JAVA_OPTS="${JAVA_OPTS} -Xmx${max_heap}m"

# Set basic java options
export JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"

# Parse HS256_KEY
if [ -n "${HS256_KEY}" ]; then
	echo "Found HS256_KEY"
	hs256_key=${HS256_KEY}
	JAVA_OPTS="${JAVA_OPTS} -Djwt.sharedSecret=${hs256_key}"
fi

# Parse CUSTOMERSERVICE_URL
if [ -n "${CUSTOMERSERVICE_URL}" ]; then
	echo "Found CUSTOMERSERVICE_URL"
	customer_url=${CUSTOMERSERVICE_URL}
	JAVA_OPTS="${JAVA_OPTS} -DcustomerService.url=${customer_url}"
fi

# disable eureka
JAVA_OPTS="${JAVA_OPTS} -Deureka.client.enabled=false -Deureka.client.registerWithEureka=false -Deureka.fetchRegistry=false"

echo "Starting Java Application"

set +x;
# Start the application
exec java ${JAVA_OPTS} -jar /app.jar