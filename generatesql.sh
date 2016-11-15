#!/bin/bash
#Initializing the review ID as a unique key to reconise all the reiews
ReviewID=0
#Echoing values to the file to crearte the table in SQL
echo -n "CREATE TABLE HotelReviews(" >> hotelreviews.sql
	echo -n "ReviewID int, " >> hotelreviews.sql
	echo -n "HotelID int, " >> hotelreviews.sql
	echo -n "OverallRating float(24), " >> hotelreviews.sql
	echo -n "AvgPrice int, " >> hotelreviews.sql
	echo -n "URL varchar(255), " >> hotelreviews.sql
	echo -n "Author varchar(64), " >> hotelreviews.sql
	echo -n "Content text, " >> hotelreviews.sql
	echo -n "Date date, " >> hotelreviews.sql
	echo -n "NoReader int, " >> hotelreviews.sql
	echo -n "NoHelpful int, " >> hotelreviews.sql
	echo -n "Overall int, " >> hotelreviews.sql
	echo -n "Value int, " >> hotelreviews.sql
	echo -n "Rooms int, " >> hotelreviews.sql
	echo -n "Location int, " >> hotelreviews.sql
	echo -n "Cleanliness int, " >> hotelreviews.sql
	echo -n "CheckIn int, " >> hotelreviews.sql
	echo -n "Service int, " >> hotelreviews.sql
	echo "BusinessService int);" >> hotelreviews.sql
#for loop to iterate through all the directory passed as an argument in the command line
for file in $1/*.dat;
do
	#Hotel ID is value assigned to each hotel in the file name where the sting hotel_ has been removed from it
	HotelID=$(basename $file .dat | sed 's/hotel_//' |  sed -e "s/'/''/g" | tr -d ',\r');
	echo $HotelID

	#HotelData is a string used to store information about the hote like URL, OverallRating etc.
	HotelData=$HotelID","
	#ElementArray contains data which is to be put in the HotelData
	ElementArray=("<Overall\sRating>" "<Avg\.\sPrice>" "<URL>");
	#for loop iterates through all the data stored in ElementArray
	for element in ${ElementArray[@]};
	do
		#currentString stores data for a specific tag
		currentString=$(grep $element $file | sed 's/'$element'//' |  sed -e "s/'/''/g" |  sed -e 's/"/""/g' | tr -d '$,\r')
		#if else statements to put the data in the file in the correct format
		if [ "$currentString" == "" ];
		then
			HotelData=$(echo $HotelData"NULL,");
		elif [ "$element" == "<URL>" ];
		then
			HotelData=$(echo $HotelData'"'$currentString'"'",")
		else
			# The first character of the string is checked to see if it is an integer between 0 and 9
			if [ ${currentString:0:1} -eq ${currentString:0:1} 2> /dev/null ];
			then
				HotelData=$(echo $HotelData$currentString",");
			else
				HotelData=$(echo $HotelData"NULL,");
			fi
		fi
	done;
	# ElementArray - stores the tags of all the informatioan that must be inserted into review data
	ElementArray=("<Author>" "<Content>" "<Date>" "<No\.\sReader>" "<No\.\sHelpful>" "<Overall>" "<Value>" "<Rooms>" "<Location>" "<Cleanliness>" "<Check\sin\s\/\sfront\sdesk>" "<Service>" "<Business\sservice>");
  #ReviewData - an array of strings used to all the data specific to a review
	ReviewData=()
	for element in ${ElementArray[@]};
	do
		#checks the current file for all instances of the data stored in element and when found formts the string and stores the final data in the currentElements array
		mapfile -t currentElements < <(grep $element $file | sed 's/'$element'//' |  sed -e "s/'/''/g" | sed -e 's/"/""/g' | tr -d '\r')
		#ReviewData stores strings which are then concatenated with the data found with the tags specifies in ElementArray
		for((i=0; i<${#currentElements[@]}; i++))
		do
			if [[ "$element" == "<Author>" || "$element" == "<Content>" || "$element" == "<Date>" ]];
			then
				ReviewData[$i]=$(echo ${ReviewData[$i]}'"'${currentElements[$i]}'"'",")
			elif [ "$element" == "<Business\sservice>" ];
			then
				ReviewData[$i]=$(echo ${ReviewData[$i]}${currentElements[$i]}")")
			else
				ReviewData[$i]=$(echo ${ReviewData[$i]}${currentElements[$i]}",")
			fi
		done;
	done;
	#for loop to iterate  through each data in ReviewData and write them to the file as an SQL Quary 
	for((i=0; i<${#ReviewData[@]}; i++))
	do
		ReviewID=$(expr $ReviewID + 1)
		echo "INSERT INTO HotelReviews (ReviewID, HotelID, OverallRating, AvgPrice, URL, Author, Content, Date, NoReader, NoHelpful, Overall, Value, Rooms, Location, Cleanliness, CheckIn, Service, BusinessService) VALUES ("$ReviewID","$HotelData${ReviewData[$i]}";" >> hotelreviews.sql
	done;
done
