#! /bin/sh
#

find $1 -depth -name "* *" -execdir rename 's/ /_/g' "{}" \;

MACHINE_COUNTER=0
COUNTER_TOTAL=0




CPUSUM=0
MEMSUM=0
COUNTER=0
TOTALSTRD_DEV_MEM=0
TOTALSTRD_DEV_CPU=0
##FILENAME to save results
FILENAME=$(echo $1 | sed -e 's/\/.*\///g')
#echo $FILENAME
#Empty the file
echo"" 
echo "CPU AND MEMORY\n--------------"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *"
  echo "Iteration | CPU Avg | Deviation CPU | Memory | Deviation Memory  (%)  "
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "log_performance_*")
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
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))


    CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
    MEMSUM=$(echo 'scale=3;'$MEMSUM + $NEWMEMAVG|bc)
    TOTALSTRD_DEV_CPU=$(echo 'scale=3;'$TOTALSTRD_DEV_CPU + $STRD_DEV_CPU|bc)
    TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
    echo $COUNTER" | "$NEWCPUAVG" | "$STRD_DEV_CPU" | "$NEWMEMAVG" | "$STRD_DEV_MEM
  done
  COUNTER=0
  echo "\n"
done

echo "Overall | "$(echo 'scale=3;'$CPUSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_CPU/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$MEMSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_MEM/$COUNTER_TOTAL|bc)





# Call setup time analysis
NEWTIME=0
STRD_DEV_TIME=0
#TOTALSTRD_DEV_BW=0
TIMESUM=0
COUNTER=0

echo "\n\nSETUP TIME\n--------------"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *"
  echo "Iteration | Time (ms)"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "*StablishmentCall*")
  do
    NEWTIME=$(cat $FILE|awk '{sum+=$1} END { print "",sum/NR}')
    #STRD_DEV_BW=$(cat $FILE.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')

    #echo $NEWBWAVG
    #echo $STRD_DEV_BW
    NEWTIME=`echo $NEWTIME | tr ',' '.'`
    echo $NEWTIME >> time_tmp_log
    #STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
    # NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
    # NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
    # STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
    # STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))

    # CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
    TIMESUM=$(echo 'scale=3;'$TIMESUM + $NEWTIME|bc)
    #TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
    # TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
    echo $COUNTER" | "$NEWTIME
  done
  echo "\n"
  COUNTER=0
done

STRD_DEV_TIME=$(cat time_tmp_log|awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}')
rm time_tmp_log

echo "Overall | "$(echo 'scale=3;'$TIMESUM/$COUNTER_TOTAL|bc)" | "$STRD_DEV_TIME" (deviation ms)"


# RTT stats

RTTSUM=0
COUNTER=0
TOTALSTRD_DEV_RTT=0
COUNTER_TOTAL=0

echo "\n\nRTT\n--------------"
#$1 contains the directory of all files used for performance

for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *"
  echo "Iteration | RTT Avg (ms) | Deviation RTT (ms)"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "*RTT*")
  do
    NEWRTTAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
    STRD_DEV_RTT=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')

    NEWRTTAVG=`echo $NEWRTTAVG | tr ',' '.'`
    STRD_DEV_RTT=`echo $STRD_DEV_RTT | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))

    RTTSUM=$(echo 'scale=3;'$RTTSUM + $NEWRTTAVG|bc)
    TOTALSTRD_DEV_RTT=$(echo 'scale=3;'$TOTALSTRD_DEV_RTT + $STRD_DEV_RTT|bc)
    echo $COUNTER" | "$NEWRTTAVG" | "$STRD_DEV_RTT
  done
  echo "\n"
  COUNTER=0
done

echo "Overall | "$(echo 'scale=3;'$RTTSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_RTT/$COUNTER_TOTAL|bc) 

#BANDWIDTH analysis
NEWBWAVG=0
STRD_DEV_BW=0
TOTALSTRD_DEV_BW=0
BWSUM=0
COUNTER=0

echo "\n\nBANDWIDTH TEST ANALYSIS\n----------------------------\n" 
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *"
  echo "SSRC | BW Avg | Deviation BW"
  #echo $FOLDER
  for FILE_SSRC in $(find $FOLDER -name "*_RV*")
  do
    SSRC=$(echo $FILE_SSRC | awk -F_ '{print $(NF-1)}' | awk -F. '{print $1F}')
    #echo $SSRC
    for FILE_SSRC_CONMON in $(find $FOLDER -name "rtp_*$SSRC*")
    do
      #echo $FILE_SSRC_CONMON
      ./perinst.awk $FILE_SSRC_CONMON > $FILE_SSRC_CONMON_bitrate.txt
       # # removing first line from bitrate.txt
      mv $FILE_SSRC_CONMON_bitrate.txt $FILE_SSRC_CONMON_bitrate.tmp
      sed 1d $FILE_SSRC_CONMON_bitrate.tmp > $FILE_SSRC_CONMON_bitrate.txt
      rm $FILE_SSRC_CONMON_bitrate.tmp
      
      NEWBWAVG=$(cat $FILE_SSRC_CONMON_bitrate.txt|awk '{sum+=$2} END { print "",sum/NR}')
      STRD_DEV_BW=$(cat $FILE_SSRC_CONMON_bitrate.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')
      NEWBWAVG=`echo $NEWBWAVG | tr ',' '.'`
      STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
      COUNTER=$((COUNTER+1))
      COUNTER_TOTAL=$((COUNTER_TOTAL+1))
      BWSUM=$(echo 'scale=3;'$BWSUM + $NEWBWAVG|bc)
      TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
      echo $COUNTER" | "$NEWBWAVG" | "$STRD_DEV_BW
      rm $FILE_SSRC_CONMON_bitrate.txt
    done
  done
  echo "\n"
  COUNTER=0
done

echo "Overall | "$(echo 'scale=3;'$BWSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_BW/$COUNTER_TOTAL|bc)
