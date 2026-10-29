# Kill all previous open nc background processes
# then open netcat in the background, waiting 1ms
# then obtaining the IP and PORT to print before 
# killing again to then print.
pkill nc
nc -lkv 1234 &   # &: in background
sleep 1
IP=$(ifconfig eth0 | awk "NR==2" | awk '{print $2}' | awk -F: '{print $2}')
PORT=$(ss -ltn | grep -i "LISTEN" | awk "NR==1" |  awk '{print $4}' |  awk -F: '{print $2}')
pkill nc

echo "The server is running at $IP, port=$PORT"

function handleAssignment() {
    echo "Heard: assignment command"
}

function handlePopulation() {
    echo "Heard: population command"
}

# Need to keep connection to client open to send
# back data. use a 
rm -f /tmp/request
mkfifo /tmp/request
while true; do
    nc -l -v 1234 < /tmp/request | {
        read -r REQUEST
        COMMAND=$( echo "$REQUEST" | tr -d '\r')

        if [ $COMMAND = "assignment" ]; then
            handleAssignment
        elif [ $COMMAND = "population" ]; then
            handlePopulation
        else
            echo "404 unknown request!"
        fi
    } > /tmp/request
done
