#!/bin/bash




# NOTE =========
# I couldn't figure out a way to do test case B 
# in the sense of handling concurrent connections in
# server.sh, so I made this instead. It may not
# fully satisfy the requirements for test case b.
# It is also quite a hacky solution.
# I totally understand if this does not pass.
# ==============





# macos nc works differently, breaking this script
# ---
# docker run --rm -it alpine sh
# apk add netcat-openbsd bash iproute2


if [ $# -ne 2 ]; then
    echo "usage: bash test_b.sh <server-ip> <port>"
    exit 1
fi

IP="$1"
PORT="$2"

# from test case A
if [ -z "$(echo "test" | nc -w 3 "$IP" "$PORT")" ]; then
    echo "test case B | FAILED TO RUN TEST CASE: server is not running"
    exit 1
fi

# echo "Warning! This case is only valid if the server is actively running."

echo "poi sydney" | nc "$IP" "$PORT" > /dev/null &
sleep 0.2

# from: https://www.cyberciti.biz/tips/linux-investigate-sockets-network-connections.html
ss -tn dport = :$PORT > /dev/null

RESPONSE=$(echo "assignment" | nc -w 5 "$IP" "$PORT")

if [ -z "$RESPONSE" ] || echo "$RESPONSE" | grep -q "^Error"; then
    echo "test case B | PASS: second request rejected."
else
    echo "test case B | FAIL: second request went through."
fi