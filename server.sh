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
    HTMLPAGE=$(curl -s https://www.sydney.edu.au/units/INFO1112/2026-S2C-ND-CC | html2text -width 1000 | grep -A2 "Assignment 2")
    if [ $? -ne 0 ]; then
        echo "Error: could not download unit page" >&2
        echo "Error: could not download unit page"
        return 1
    fi
    
    echo "$HTMLPAGE" >&2

    ASSIGNMENT_TITLE=$(echo "$HTMLPAGE" | awk "NR==1" | awk -F'  +' '{print $2}')
    ASSIGNMENT_TOPIC=$(echo "$HTMLPAGE" | awk "NR==2" | awk -F'  +' '{print $2}') # The true field is 'Programming task - Networking Concepts' NOT just 'Networking'. This is an error in the assignment description.
    ASSIGNMENT_DUE_DATE=$(echo "$HTMLPAGE" | awk "NR==2" | awk -F'  +' '{print $4}' | awk -F: '{print $2":"$3}')
    ASSIGNMENT_POINTS=$(echo "$HTMLPAGE" | awk "NR==2" | awk -F'  +' '{print $3}' | awk -F'%' '{print $1}')

    ASSIGNMENT_JSON=$(jq -n --arg title "$ASSIGNMENT_TITLE" --arg topic "$ASSIGNMENT_TOPIC" --arg due "$ASSIGNMENT_DUE_DATE" --arg points "$ASSIGNMENT_POINTS" '{title: $title, topic: $topic, due_date: $due, points: $points}')

    echo "$ASSIGNMENT_JSON"
}

function handlePopulation() {
    CSVPAGE=$(curl -s https://dbr.abs.gov.au/processedData/csv/STE_1.csv)
    if [ $? -ne 0 ]; then
        echo "Error: could not download NSW population data" >&2
        echo "Error: could not download NSW population data"
        return 1
    fi

    POPULATION=$(echo "$CSVPAGE" | awk "NR==2" | awk -F, '{print $NF}')
    echo "Population of NSW: $POPULATION" >&2
}

# Need to keep connection to client open to send
# back data. 
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
            echo "Error: Unknown Request!"
        fi
    } > /tmp/request
done
