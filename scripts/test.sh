#! /bin/sh

#Calculate packet loss
#BANDWIDTH analysis
NEWBWAVG=0
STRD_DEV_BW=0
TOTALSTRD_DEV_BW=0
BWSUM=0
COUNTER=0
MACHINE_COUNTER=0
COUNTER_TOTAL=0
echo "Doing packet losses..."
echo "\n\PACKET LOSSES\n----------------------------\n" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find /Users/Albert/Desktop/MTesis/results/no_ipfw_turn_foreman -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" | column -t >> $FILENAME".log"
  echo "Iteration | Packets" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE_PL in $(find $FOLDER -name "*_PLvideo*")
  do
    echo $(cat $FILE_PL | awk '{ sum += $2; } END { print sum; }')
    COUNTER=$((COUNTER+1))
  done
done
