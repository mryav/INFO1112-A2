# start netcat
# &: in background
nc -lk 1234 &

# Get the IP and port
IP=$(ifconfig eth0 | awk "NR==2" | awk '{print $2}')
PORT=$(ss -ltn | grep -i "LISTEN" | awk "NR==1" |  awk '{print $4}' |  awk -F: '{print $2}')

echo "The server is running at $IP, port=$PORT"
echo "........................................"

# Keep script running forever
wait