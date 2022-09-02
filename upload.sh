#!/bin/sh
trap "echo Goodbye" EXIT

# Reference: http://roboojack.blogspot.in/2014/12/bulk-upload-your-local-maven-artifacts.html

# command demo: bash   upload.sh ~/Documents/qkk/Program/localRepository nexus http://localhost:8081/repository/maven-releases kkk

if [ "$#" -ne 4 ] || ! [ -d "$1" ]; then
    echo "Usage:"
    echo "       bash run.sh <repoRootFolder> <repositoryId> <repositoryUrl> <keyword>"
    echo ""
    echo ""
    echo "       Where..."
    echo "       absolute repoRootFolder: The folder containing the repository tree."
    echo "                       Ensure you move the repository outside of ~/.m2 folder"
    echo "                       or whatever is configured in settings.xml"
    echo "       repositoryId:   The repositoryId from the <server> configured for the repositoryUrl in settings.xml."
    echo "                       Ensure that you have configured username and password in settings.xml."
    echo "       repositoryUrl:  The URL of the repository where you want to upload the files."
    echo "       keyword:  The keyword of the path where you want to filter the files."
    exit 1
fi

while read -r line ; do
	if ! [[ $line =~ $4 ]]; then
		continue
	fi
	url=$3
	if [[ $line =~ SNAPSHOT ]]; then
           #for snaphost ,replace with snapshot repository
	   url=${url/%releases/snapshots}
	   echo $url	
	fi
    	echo "Processing file $line"

    pomLocation=${line/.jar/.pom}
    jarLocation=${line/.pom/.jar}
    sourceLocation=${line/.pom/-sources.jar}
#    echo $pomLocation
 #   echo $jarLocation
#echo $sourceLocation
    if [[ -e $jarLocation ]] && [[ -e $sourceLocation ]]; then
	echo "both exist"	
    mvn deploy:deploy-file -DpomFile=$pomLocation -Dfile=$jarLocation -Dsources=$sourceLocation  -DrepositoryId=$2 -Durl=$url
    elif [[ -e $jarLocation ]]; then
		
	echo "jar exist"	
    mvn deploy:deploy-file -DpomFile=$pomLocation -Dfile=$jarLocation  -DrepositoryId=$2 -Durl=$url
    elif [[ -e $sourceLocation ]]; then

	echo "source exist"	
    mvn deploy:deploy-file -DpomFile=$pomLocation -Dsources=$sourceLocation  -DrepositoryId=$2 -Durl=$url
    else
	
	echo "pom exist"	
    mvn deploy:deploy-file -DpomFile=$pomLocation -Dfile=$pomLocation  -DrepositoryId=$2 -Durl=$url
    fi
done < <(find $1 -name "*.pom")


