addPools.sh

This Script is responsible to create new pools given in pools.csv file

================================================================================
PREREQUISITES
================================================================================
1. Host server address of glue web app. (HOST)
2. Running glue server on (HOST).
3. pools.csv file containing poolName, location, active(true/false), exclusive(true/false) and customerGuid(optional, only if exclusive is true). (poolName,location,active,exclusive,customerGuid)

================================================================================
HOW TO USE
================================================================================
Given below are mandatory arguments to run the script

-h : Host server address

================================================================================
Add new pools
================================================================================

1. Go to the directory containing addPools.sh and pools.csv file
2. run given below command:

./addPools.sh -h=<HOST>

sample:
./addPools.sh -h=http://localhost:9090

* This will read the pool information from pools.csv file and add pools to database through glue api calls.
* Result will be logged in a log file in same directory.
* For Successful update you will see response code 200 with reponse body
  otherwise proper error message will be logged for each request.
