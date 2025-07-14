# CheckNetworksInsideDocker




# Put all needed objects from the json into lists
I take every needed object from the json and put it in a list so it will be easier to work with.
Every command have the same structure: listName = ($(jq -r '.database.containers[].<object>' FileName.json))


# Spaces for cleaner view in the CLI
echo -e "\n\n\n\n"

# loop on every object in the json using the lists
for ((i=0; i<${#containers[@]}; i++)); do

	# Create variables of current used object
	container="${listOfContainers[$i]}"
	currentNic="${listOfNics[$i]}"
	currentPort="${listOfPorts[$i]}"
	currentSource="${listOfSources[$i]}"
	currentDestination="${listOfDestinations[$i]}"

	# Check if the current container exists (if no container found the var remains empty)
	currentContainer=$(docker ps --format '{{.Names}}' | grep "$container")

	# If no container found
	if [ -z "$currentContainer" ]; then
		echo "  No active container named: $container"
	else
	  
		# Ping check from inside of the container (if no ping returned the var remains empty)
		pingResponseFromContainer=$(docker exec -it "$currentContainer" timeout 2 tcpdump -i "$currentNic" -c 1 -nn port "$currentPort")
		
		# docker exec 				- 	execute the command after the specified container
		# timeout 2 				- 	wait two seconds for ping before giving up
		# tcpdump -i "$currentNic" 	- 	get network packages coming from the specified NIC
		# -c 1 						- 	wait for one packege before returning a positive answer
		# -nn port "$currentPort"	-	listen to the traffic throught a specific port	
		
	# If ping accepted
	if [ "$(echo "$pingResponseFromContainer" | grep $currentPort)" ]; then	
	  echo "  $currentContainer : Success"

	# If no ping accepted
	else	
		  echo "  $currentContainer : No traffic"		
	fi

	# Print General information
	echo " From: $currentSource    To: $currentDestination    (Port $currentPort)"	
	
  fi
  echo " "
done


# Spaces for cleaner view in the CLI
echo -e "\n\n\n\n"
