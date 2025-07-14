#!/bin/bash



# Put all container names into a list
listOfContainers=($(jq -r '.database.containers[].grep' containers_example.json))

# Put all NICs into a list
listOfNics=($(jq -r '.database.containers[].NIC' containers_example.json))

# Put all ports into a list
listOfPorts=($(jq -r '.database.containers[].port' containers_example.json))

# Put all sources into a list
listOfSources=($(jq -r '.database.containers[].from' containers_example.json))

# Put all destinations into a list
listOfDestinations=($(jq -r '.database.containers[].to' containers_example.json))


# Spaces
echo -e "\n\n\n\n"

# Check each objet in the lists
for ((i=0; i<${#containers[@]}; i++)); do

	# Variables
	container="${listOfContainers[$i]}"
	currentNic="${listOfNics[$i]}"
	currentPort="${listOfPorts[$i]}"
	currentSource="${listOfSources[$i]}"
	currentDestination="${listOfDestinations[$i]}"

	# Check if container exists
	currentContainer=$(docker ps --format '{{.Names}}' | grep "$container")

	# If no container found
	if [ -z "$currentContainer" ]; then
		echo "  No active container named: $container"
	else
	  
    # Ping check from inside of the container
		pingResponseFromContainer=$(docker exec -it "$currentContainer" timeout 2 tcpdump -i "$currentNic" -c 1 -nn port "$currentPort")
		
    # Ping accepted
		if [ "$(echo "$pingResponseFromContainer" | grep $currentPort)" ]; then	
      echo "  $currentContainer : Success"
    
    # No ping   
		else	
		  echo "  $currentContainer : No traffic"		
		fi
    
    # General information
    echo " From: $currentSource    To: $currentDestination    (Port $currentPort)"	
	
  fi
  echo " "
done



echo -e "\n\n\n\n"
