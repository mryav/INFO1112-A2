#!/bin/bash

# macos nc works differently, breaking this script
# ---
# docker run --rm -it alpine sh 
# apk add netcat-openbsd bash

if [ $# -ne 2 ]; then
    echo "usage: bash test_1.sh <server-ip> <port>"
    exit 1
fi

IP="$1"
PORT="$2"



RESPONSE=$(echo "test" | nc -w 3 "$IP" "$PORT" 2>/dev/null)
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "nc error: exit code ${STATUS}"
    echo "PASS: nc returned an error because the server is not running, and the Docker container is unreachable."
    exit 0
fi

if [ -n "$RESPONSE" ]; then
    echo "test case A | FAIL: nc connected successfully. response: $RESPONSE"
    exit 1
else 
    echo "test case A | PASS: server is not running or busy."
fi

