#!/usr/bin/env bash
#PLEASE READ README.TXT FILE BEFORE RUNNING THIS SCRIPT

# parse arguments
for i in "$@"
do
case $i in
    -h=*|--host=*)
    HOST_ADDR="${i#*=}"
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
    echo 'All arguments are either wrong or not available. Exiting.'
    exit 0
    ;;
esac
done

#add spinner
sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}

# Print and start execution
echo "Adding pools"

#Start execution
fileName="log-$(date +%Y-%m-%d_%H-%M-%S).txt"
COUNTER=0
SUCCESSFUL=0
FAILURE=0
INPUT=pools.csv
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read poolName location active exclusive customerGuid
do
	#start spinner
	spin

	#Execute curl command
	#prepare POST in case pool is exclusive
	if $exclusive; then
	    restResult=$(curl \
	    -sL -w "\\nRequest :: %{http_code} %{url_effective}\\n" \
	    -H "Content-Type: application/json" \
	    -H "Accept: application/json" \
	    -X POST \
	    -d "{\"PoolName\": \"$poolName\", \"Location\": \"$location\", \"Active\": \"$active\", \"Exclusive\": \"$exclusive\", \"CustomerGuid\": \"$customerGuid\"}" \
	    $HOST_ADDR/1/0/workspaceserverpool/workspaceserverpools \
	    )
	#prepare POST in case pool is not exclusive
	else
	   restResult=$(curl \
	   -sL -w "\\nRequest :: %{http_code} %{url_effective}\\n" \
	   -H "Content-Type: application/json" \
	   -H "Accept: application/json" \
	   -X POST \
	   -d "{\"PoolName\": \"$poolName\", \"Location\": \"$location\", \"Active\": \"$active\"}" \
	   $HOST_ADDR/1/0/workspaceserverpool/workspaceserverpools \
	   )
	fi
	 #curl end

	#log result
	formattedResult="$(date -u) :: \nResponse :: $restResult\nBody :: {\"PoolName\":\"$poolName\"}\n"
	echo -e "$formattedResult" >> "$fileName"

	#print counters
	if [[ $formattedResult == *"Request :: 200"* ]]
	then
	    let SUCCESSFUL=SUCCESSFUL+1
	else
		let FAILURE=FAILURE+1
	fi

	let COUNTER=COUNTER+1
    echo -ne " Processed: $COUNTER | Successful: $SUCCESSFUL | Failure: $FAILURE"'\r'

done < $INPUT
IFS=$OLDIFS

#end spinner
endspin