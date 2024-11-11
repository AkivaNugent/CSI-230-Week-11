#! /bin/bash

logFile="/var/log/apache2/access.log"

function displayAllLogs(){
	cat "$logFile"
}

function displayOnlyIPs(){
        cat "$logFile" | cut -d ' ' -f 1 | sort -n | uniq -c
}

# function: displayOnlyPages:
# like displayOnlyIPs - but only pages
function displayOnlyPages(){
	cat "$logFile" | cut -d' ' -f 7 | sort -n | uniq -c 
}

function histogram(){

	local visitsPerDay=$(cat "$logFile" | cut -d " " -f 4,1 | tr -d '['  | sort \
                              | uniq)
	# This is for debugging, print here to see what it does to continue:
	# echo "$visitsPerDay"

        :> newtemp.txt  # what :> does is in slides
	echo "$visitsPerDay" | while read -r line;
	do
		local withoutHours=$(echo "$line" | cut -d " " -f 2 \
                                     | cut -d ":" -f 1)
		local IP=$(echo "$line" | cut -d  " " -f 1)
          
		local newLine="$IP $withoutHours"
		echo "$IP $withoutHours" >> newtemp.txt
	done 
	cat "newtemp.txt" | sort -n | uniq -c
}

# function: frequentVisitors: 
# Only display the IPs that have more than 10 visits
# You can either call histogram and process the results,
# Or make a whole new function. Do not forget to separate the 
# number and check with a condition whether it is greater than 10
# the output should be almost identical to histogram
# only with daily number of visits that are greater than 10 
function frequentVisitors(){
	freqLogs=$(histogram)
	while read -r line;
	do
		count=$(echo "$line" |cut -d " " -f1)
		if [[ "$count" -ge '10' ]]; then
			echo "$line"
		fi

	done <<< "$freqLogs"
}
# function: suspiciousVisitors
# Manually make a list of indicators of attack (ioc.txt)
# filter the  records with this indicators of attack
# only display the unique count of IP addresses.  
# Hint: there are examples in slides
function suspiciousVisitors(){
	indicators=$(cat "ioc.txt")
	allLogs=$(cat "$logFile")
	susLogs=$(echo "$allLogs" | egrep "$indicators" |cut -d " " -f 1 | sort | uniq -c ) 
	echo "$susLogs"
}
# Keep in mind that I have selected long way of doing things to 
# demonstrate loops, functions, etc. If you can do things simpler,
# it is welcomed.

while :
do
	echo "PLease select an option:"
	echo "[1] Display all Logs"
	echo "[2] Display only IPS"
	# Display only pages visited
	echo "[3] Display only pages"
	echo "[4] Histogram"
	# Frequent visitors
	echo "[5] Frequent Visitors"
	# Suspicious visitors
	echo "[6] Sussy Visistors"
	echo "[7] Quit"

	read userInput
	echo ""

	if [[ "$userInput" == "7" ]]; then
		echo "Goodbye"		
		break

	elif [[ "$userInput" == "1" ]]; then
		echo "Displaying all logs:"
		displayAllLogs

	elif [[ "$userInput" == "2" ]]; then
		echo "Displaying only IPS:"
		displayOnlyIPs

	# Display only pages visited
	elif [[ "$userInput" == "3" ]]; then
		echo "Displaying only pages:"
		displayOnlyPages

	elif [[ "$userInput" == "4" ]]; then
		echo "Histogram:"
		histogram

        # Display frequent visitors
	elif [[ "$userInput" == "5" ]]; then
		echo "Displaying frequent Visitors:"
		frequentVisitors
	# Display suspicious visitors
	elif [[ "$userInput" == "6" ]]; then
		echo "Displaying suspicious Visitors:"
		suspiciousVisitors
	# Display a message, if an invalid input is given
	else echo "invalid input"

	fi
done


