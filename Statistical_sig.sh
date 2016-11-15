#!/bin/bash
for f in $@;
do
	echo -n $(basename $f) ""
	grep "<Overall>" "reviews_folder/$f.dat" | egrep -o "[0-9]+" | awk '{
		count+=1; 
		SUM+= $1;
		Sum_square+=$1^2;
	} END{  
		printf"%d %d %d ",count,SUM,Sum_square;
		
}'
done | awk '{
	
	split($1" "$5, hotelName, " ");
	split($2" "$6,count," ");
	split($3" "$7,sum," ");
	split($4" "$8,Sum_square," ");
	for (i=1;i<=2;i++){
		sd[i] = sqrt( ( Sum_square[i] - ( sum[i]^2 / count[i] ) ) / ( count[i] - 1) );
	} 
	df=count[1]+count[2]-2;
	sx1x2 = sqrt( ( ( count[1]-1 )*sd[1]^2 + ( count[2]-1 )*sd[2]^2  ) / df );

	t= ( (sum[1]/count[1] - sum[2]/count[2])/(sx1x2 * sqrt( 1/count[1]+1/count[2])));

	printf"t : %.2f \n",t;
	for(i =1; i<=2;i++){
	 printf" Mean %s : %.2f SD : %.2f\n",hotelName[i],sum[i]/count[i],sd[i];
	}
	if(t>1.965261468090270)
		print"1"; #Significant
	else
		print"0"; #insignificant
	
}'
