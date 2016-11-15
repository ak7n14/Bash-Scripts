#!/bin/bash
for f in $1/*.dat;
do
	echo -n $(basename $f) ""
	grep "<Overall>" $f | egrep -o "[0-9]+" | awk '{
		count+=1; 
		SUM+= $1;
	} END{ 
		print SUM/count}'
done | sort -nrk2
#Best 2 hotels = hotel_188937.dat rating 4.77953 , hotel_203921.dat 4.77778
