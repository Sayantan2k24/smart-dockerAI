#!/bin/bash
# Function to show the beginner menu  
show_beginner_menu() {


while :
do
    choice=$(zenity --list --title="Container Management Tool [BEGINNER Mode]" --width=500 --height=400  --column="Option" --column="Description" \
	  0 "Main Menu"\
        1 "Check Docker Service Status" \
        2 "Check If Docker Is Installed" \
        3 "Install The Docker-CE" \
        4 "Check If Docker Is Enabled" \
        5 "List All The Containers Including Stopped Ones" \
        6 "List All The Running Containers Only" \
        7 "List The Available Images" \
        8 "Launch A Container" \
        9 "Stop A Container" \
        10 "Stop All The Running Containers" \
        11 "Download/Pull A Docker Image" \
        12 "Delete A Docker Image" \
        13 "Remove A Docker Container" \
        14 "Stop All The Running Containers" \
        15 "Remove All The Running Containers Only" \
        16 "Remove All The Containers" \
        17 "Start All The Stopped Containers" \
        18 "Restart a Container" \
        19 "Restart All Containers" \
        20 "View Container Logs" \
	  21 "Create A Dockerfile" \
	  22 "Inspect the Docker Image" \
	  23 "Create A DockerFile with the help of AI Assistant"\
	  24 "Build DockerImage" \ )




case $choice in
	1) 
		echo -e "Checking Docker Service Status...\n" 
		systemctl status docker 
		;;

	2)
		if `docker -v > /dev/null 2>&1`;
		then
			echo "Docker is installed"
		else
			echo "Docker is not Installed"
		fi
		;;

	3)	
		if ! docker -v > /dev/null 2>&1; 
		then
      		echo "Docker not found. Installing Docker..." &&
        		dnf -y install dnf-plugins-core &&
        		dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &&
        		dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &&
        		echo "Docker installation completed."
		else
        		echo "Docker is already installed."
		fi
		;;
		
    	4)
		echo "Checking if Docker is enabled on startup..."
        	systemctl is-enabled docker
        	;;
   	5)
        	echo "Listing all containers..."
        	docker ps -a
        	;;
    	6)
        	echo "Listing only the running containers"
        	docker ps
        	;;
    	7)
        	echo "Listing the available images"
        	docker images
        	;;
    	8)
        	read -p "Enter the container name: " containerName
		#check if container exists with the same name
        	while `docker ps -a --format "{{.Names}}" | grep "\b${containerName}\b" >> /dev/null`
        	do
            	echo "Name exists"
            	read -p "Try Another Name: " containerName
        	done
        
      		echo "yes $containerName is unique"
        
        	echo -e "\nLocally Available Images"
        	echo -e "==========================="
        	docker images | awk 'NR!=1 {print $1 ":" $2 }'
        	echo -e "===========================\n"
            
        	read -p "Give the image name here: " imageName
        
        	read -p "Run in background as a daemon?[y/N]: " isDaemon 
        
        	if [[ $isDaemon == "y" ]]
        	then
            	`docker run -dit --name $containerName  $imageName > /dev/null` && 
            	echo -e "container is launched in the daemon mode\n" &&
            	echo -e "The container ID: `docker ps -a | grep "\b${containerName}\b" | awk '{ print $1 }'`\n"
            
        	else    
            	docker run -it --name $containerName $imageName && 
            	echo -e "The container ID: `docker ps -a | grep "\b${containerName}\b" | awk '{ print $1 }'`\n"
            
        	fi
        	;;
    	9)
        	echo "These are the running containers"
       	echo -e "================================\n"
        
        	docker ps && echo -e "====================================================\n"
        
        	read -p "Enter the Name or the ID of that container to be stopped: " NameOrId
        	docker stop $NameOrId >> /dev/null  && echo "Container stopped successfully: ${NameOrId}" 
        	;;
    	10)
        	if [[ `docker ps  | wc -l` -eq 1 ]] # 1 means only the headers are showing -- means no container is at running state
        	then 
            	echo "No container is at running state"
        	else
            	echo "Stopping the containers"
            	docker stop $(docker ps -q) 
            	echo "stopped all the running containers"
        	fi
        	;;
    	11)
        	read -p "Enter Image and version [imageName:version]: " image

        	# Check if the user provided a version
        	if [[ $image != *:* ]]; 
        	then
            	image="${image}:latest"
        	fi

        	docker pull "$image"
        	;;
    	12)
		echo -e "\nLocally Available Images"
        	echo -e "==========================="
        	docker images | awk 'NR!=1 {print $1 ":" $2 }'
        	read -p "Enter the image to delete: " image
        	docker rmi $image
        	;;
    	13)
        	echo "List of All the Containers"
        	docker ps -a
        	read -p  "Enter Name or ID: " NameOrId
        	docker rm -f $NameOrId > /dev/null && echo "Container Successfully Removed: $NameOrId"
        	;;
    	14)
        	echo -e "Stopping all the running containers...\n"
        	docker stop $(docker ps -q)
        	;;
    	15)
        	echo -e "Removing only the running Containers...\n"
        	docker rm -f $(docker ps -q)
        	;;
    	16)
        	echo -e "Removing all the Containers...\n"
        	docker rm -f $(docker ps -a -q)
        	;;
	17) 
		echo -e "Starting all the stopped Containers...\n" 
		docker start $(docker ps -a -q -f status=exited) 
		;;
    	18)
        	echo -e "Restarting A Container...\n"
        	read -p "Enter container ID or name: " container
        	docker restart $container
        	;;
    	19)
        	echo -e "Restarting All Containers...\n"
        	docker restart $(docker ps -q)
        	;;
   	20)	
		
		echo -e "First Listing all the containers..\n"
		
		docker ps -a
        	
        	read -p "Enter container ID or name: " container
		echo -e "Viewing Container Logs...\n"

        	docker logs $container
        	;;

    	21)	echo -e "Inspecting A Container...\n"
		echo -e "First Listing all the containers..\n"
		
		docker ps -a
		
        	read -p "Enter container ID or name: " container
		
        	docker inspect $container | jq
        	;;
    	22)
		
		echo -e "Inspecting An Image...\n"
		echo -e "\nLocally Available Imcdages"
		
		docker images
        	
        	read -p "Enter image name: " image
		
        	docker inspect $image
        	;;
	23) 
		echo "Welcome, Here is your AI Assistant to help you Create a Dockerfile"
		
		read -p "Prompt me about your requirement in detail: " prompt
		
		output=`aichat -c "$prompt" 2> /dev/null`
		
		if [[ $? -eq 0 ]] 
		then
			echo "$output" >> Dockerfile
			echo "Dockerfile Generated.."
		else
			echo "Failed to generate Dockerfile"
		fi
		;;
		
	24) 	
		read -p "Provide a name for the Docker image in [image:version] format (e.g., myapp:1.0):" imageName
    		
		echo "Building Docker Image.."
		docker build -t $imageName .
		
		if [[ $? -eq 0 ]]
		then
			echo "$imageName Image Built Successfully.."
    		else
			echo "Failed to build Docker Image"
		fi
		;;
		
	0) 	echo "Returning To Main Menu............."
		sleep 1
		return
		;;	

	*)
        	echo "Invalid choice. Please choose between 0 to 17."
		
        	;;
esac

done

}


# Function to show the pro menu  
show_pro_menu() 
{ 

while :
do

proChoice=$(zenity --list --title="Container Management Tool [PRO mode]" --width=400 --height=200 --column="Option" --column="Description"  0 "Main Menu" 1 "Docker Management" )
	
case $proChoice in
	1)	
		read -p "Prompt me what you need me to do:" prompt
		aichat -e $prompt
		;;

	0) 
		echo "Returning to Main Menu..."
		sleep 1		
		return
		;;
	*)
		echo "Invalid Option"	
		;;

	esac
done	
	
} 

# Main script 
while : 
do 


mode=$(zenity --list --title="Container Management Tool" --width=300 --height=200 --column="Option" --column="Description"  1 "Beginner Mode"  2 "Pro Mode"  3 "Exit" ) 

case $mode in 
	1) 
		show_beginner_menu 
		;; 
	2) 	
		show_pro_menu
		;;	
	3)	
		echo "GoodBye!...."
		sleep 1
		exit
		;;
	*) 
		echo "invalid: Select Among Those Options only"
		;;
esac

done
