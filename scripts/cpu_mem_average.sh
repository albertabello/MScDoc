#! /bin/sh
# Calculates average of CPU and RAM of all logfiles

CPUSUM=0
MEMSUM=0
COUNTER=0
TOTALSTRD_DEV_MEM=0
TOTALSTRD_DEV_CPU=0
##FILENAME to save results
FILENAME=$(echo $1 | sed -e 's/\/.*\///g')
#echo $FILENAME
#Empty the file
echo"" > $FILENAME".log" 
echo "CPU AND MEMORY\n--------------" >> $FILENAME".log"
echo "Iteration | CPU Avg | Deviation CPU | Memory | Deviation Memory   " >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FILE in $(find $1 -name 'log_performance_*')
do 

	NEWMEMAVG=$(cat $FILE|awk '{sum+=$3} END { print "",sum/NR}')
	NEWCPUAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
	STRD_DEV_CPU=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')
	STRD_DEV_MEM=$(cat $FILE|awk '{sum+=$3; sumsq+=$3*$3} END {print sqrt(sumsq/NR - (sum/NR)**2)}')


	NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
	NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
	STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
	STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
	COUNTER=$((COUNTER+1))

	CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
	MEMSUM=$(echo 'scale=3;'$MEMSUM + $NEWMEMAVG|bc)
	TOTALSTRD_DEV_CPU=$(echo 'scale=3;'$TOTALSTRD_DEV_CPU + $STRD_DEV_CPU|bc)
	TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
	echo $COUNTER" | "$NEWCPUAVG" | "$STRD_DEV_CPU" | "$NEWMEMAVG" | "$STRD_DEV_MEM>> $FILENAME".log"


done

echo "Total | "$(echo 'scale=3;'$CPUSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_CPU/$COUNTER|bc)" | "$(echo 'scale=3;'$MEMSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_MEM/$COUNTER|bc) >> $FILENAME".log"


