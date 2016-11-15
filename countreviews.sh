#!/bin/bash
for f in $1/*.dat;
do
	echo -n $(basename $f)" "
        grep '<Author>' $f |wc -l
done | sort -nrk2



