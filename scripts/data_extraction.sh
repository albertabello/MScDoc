#! /bin/sh
# Calculates average of CPU and RAM of all logfiles

# Deletes spaces in folder name to avoid errors
find $1 -depth -name "* *" -execdir rename 's/ /_/g' "{}" \;
#rm -r output_delay/*
mkdir -p $1/output
#Empty files for temp results
#echo "" > BW_DATA.dat
echo "" > BW_DATA_2.dat
echo "" > BW_DATA_1.dat
echo "" > CPU_MEM_DATA.dat
echo "" > RTT.dat
echo "" > SETUP_TIME.dat

MACHINE_COUNTER=0
COUNTER_TOTAL=0
CPUSUM=0
MEMSUM=0
COUNTER=0
TOTALSTRD_DEV_MEM=0
TOTALSTRD_DEV_CPU=0
TMPDEVMEM=0
TMPDEVCPU=0
TMPCPUSUM=0
TMPMEMSUM=0
##FILENAME to save results
FILENAME=$1/output/$(echo $1 | sed -e 's/\/.*\///g')
#echo $FILENAME
#Empty the file
echo"" > $FILENAME".log" 
echo "Doing CPU/Memory..."
echo "CPU AND MEMORY\n--------------" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" | column -t >> $FILENAME".log"
  echo "Iteration | CPU Avg | Deviation CPU | Memory | Deviation Memory (%)  " | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "log_performance_*")
  do

    NEWMEMAVG=$(cat $FILE|awk '{sum+=$3} END { print "",sum/NR}')
    NEWCPUAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
    STRD_DEV_CPU=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
    STRD_DEV_MEM=$(cat $FILE|awk '{sum+=$3; sumsq+=$3*$3} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')


    NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
    NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
    STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
    STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))


    CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
    MEMSUM=$(echo 'scale=3;'$MEMSUM + $NEWMEMAVG|bc)
    TMPCPUSUM=$(echo 'scale=3;'$TMPCPUSUM + $NEWCPUAVG|bc)
    TMPMEMSUM=$(echo 'scale=3;'$TMPMEMSUM + $NEWMEMAVG|bc)
    TMPDEVMEM=$(echo 'scale=3;'$TMPDEVMEM + $STRD_DEV_MEM|bc)
    TMPDEVCPU=$(echo 'scale=3;'$TMPDEVCPU + $STRD_DEV_CPU|bc)
    TOTALSTRD_DEV_CPU=$(echo 'scale=3;'$TOTALSTRD_DEV_CPU + $STRD_DEV_CPU|bc)
    TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
    echo $COUNTER"\t"$NEWCPUAVG"\t"$STRD_DEV_CPU"\t"$NEWMEMAVG"\t"$STRD_DEV_MEM >> "CPU_MEM_DATA.dat"
    echo $COUNTER" | "$NEWCPUAVG" | "$STRD_DEV_CPU" | "$NEWMEMAVG" | "$STRD_DEV_MEM | column -t >> $FILENAME".log"
  done
  echo "\n" >> $FILENAME".log"
  echo "Machine $MACHINE_COUNTER | "$(echo 'scale=3;'$TMPCPUSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TMPDEVCPU/$COUNTER|bc)" | "$(echo 'scale=3;'$TMPMEMSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TMPDEVMEM/$COUNTER|bc) | column -t >> $FILENAME".log"
  COUNTER=0
  TMPCPUSUM=0
  TMPMEMSUM=0
  TMPDEVMEM=0
  TMPDEVCPU=0
  echo "\n" >> $FILENAME".log"
done

echo "Overall | "$(echo 'scale=3;'$CPUSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_CPU/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$MEMSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_MEM/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"

#Calculate packet loss
NEWPL=0
PLSUM=0
COUNTER=0
MACHINE_COUNTER=0
COUNTER_TOTAL=0
TMPPLSUM=0
echo "Doing packet losses..."
echo "\n\nPACKET LOSSES\n----------------------------\n" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" | column -t >> $FILENAME".log"
  echo "Iteration | Packets" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE_PL in $(find $FOLDER -name "*_PLvideo*")
  do
    NEWPL=$(cat $FILE_PL | awk '{ sum += $2; } END { print sum; }')
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))
    PLSUM=$(echo 'scale=3;'$PLSUM + $NEWPL|bc)
    TMPPLSUM=$(echo 'scale=3;'$TMPPLSUM + $NEWPL|bc)
    echo $COUNTER"\t"$NEWPL>> "PL_DATA_$MACHINE_COUNTER.dat"
    echo $COUNTER" | "$NEWPL | column -t >> $FILENAME".log"
  done
  echo "\n" >> $FILENAME".log"
  echo "Machine $MACHINE_COUNTER | "$(echo 'scale=3;'$TMPPLSUM/$COUNTER|bc) | column -t >> $FILENAME".log"
  echo "\n" >> $FILENAME".log"
  COUNTER=0
  TMPPLSUM=0
done

echo "Overall | "$(echo 'scale=3;'$PLSUM/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"

# Call setup time analysis
NEWTIME=0
STRD_DEV_TIME=0
#TOTALSTRD_DEV_BW=0
TIMESUM=0
COUNTER=0
MACHINE_COUNTER=0 
COUNTER_TOTAL=0
TMPSTSUM=0
echo "Doing call stablishment time..."
echo "\n\nSETUP TIME\n--------------" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" >> $FILENAME".log"
  echo "Iteration | Time (ms)" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "*StablishmentCall*")
  do
    NEWTIME=$(cat $FILE|awk '{sum+=$1} END { print "",sum/NR}') 
    #STRD_DEV_BW=$(cat $FILE.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}')

    #echo $NEWBWAVG
    #echo $STRD_DEV_BW
    NEWTIME=`echo $NEWTIME | tr ',' '.'`
    echo $NEWTIME >> time_tmp_log
    echo $NEWTIME >> time_tmp_log_individual
    #STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
    # NEWCPUAVG=`echo $NEWCPUAVG | tr ',' '.'`
    # NEWMEMAVG=`echo $NEWMEMAVG | tr ',' '.'`
    # STRD_DEV_MEM=`echo $STRD_DEV_MEM | tr ',' '.'`
    # STRD_DEV_CPU=`echo $STRD_DEV_CPU | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))

    # CPUSUM=$(echo 'scale=3;'$CPUSUM + $NEWCPUAVG|bc)
    TIMESUM=$(echo 'scale=3;'$TIMESUM + $NEWTIME|bc)
    TMPSTSUM=$(echo 'scale=3;'$TMPSTSUM + $NEWTIME|bc)
    #TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
    # TOTALSTRD_DEV_MEM=$(echo 'scale=3;'$TOTALSTRD_DEV_MEM + $STRD_DEV_MEM|bc)
    echo $COUNTER"\t"$NEWTIME >> "SETUP_TIME.dat"
    echo $COUNTER" | "$NEWTIME | column -t >> $FILENAME".log"
  done
  TMP_STRD_DEV_TIME=$(cat time_tmp_log_individual|awk '{sum+=$1; sumsq+=$1*$1} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
  echo "\n" >> $FILENAME".log"
  echo "Machine $MACHINE_COUNTER | "$(echo 'scale=3;'$TMPSTSUM/$COUNTER|bc)" | "$TMP_STRD_DEV_TIME" (deviation ms)" | column -t >> $FILENAME".log"
  echo "\n" >> $FILENAME".log"  
  COUNTER=0
  TMPSTSUM=0
  rm time_tmp_log_individual
done

STRD_DEV_TIME=$(cat time_tmp_log|awk '{sum+=$1; sumsq+=$1*$1} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
rm time_tmp_log

echo "Overall | "$(echo 'scale=3;'$TIMESUM/$COUNTER_TOTAL|bc)" | "$STRD_DEV_TIME" (deviation ms)" | column -t >> $FILENAME".log"


# RTT stats

RTTSUM=0
COUNTER=0
TOTALSTRD_DEV_RTT=0
COUNTER_TOTAL=0
MACHINE_COUNTER=0
TMPTRTTSUM=0
TMP_DEV_RTT=0
echo "Doing RTT..."
echo "\n\nRTT\n--------------" >> $FILENAME".log"
#$1 contains the directory of all files used for performance

for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" >> $FILENAME".log"
  echo "Iteration | RTT Avg | Deviation RTT (ms)" | column -t >> $FILENAME".log"
  #echo $FOLDER
  for FILE in $(find $FOLDER -name "*RTT*")
  do
    NEWRTTAVG=$(cat $FILE|awk '{sum+=$2} END { print "",sum/NR}')
    STRD_DEV_RTT=$(cat $FILE|awk '{sum+=$2; sumsq+=$2*$2} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')

    NEWRTTAVG=`echo $NEWRTTAVG | tr ',' '.'`
    STRD_DEV_RTT=`echo $STRD_DEV_RTT | tr ',' '.'`
    COUNTER=$((COUNTER+1))
    COUNTER_TOTAL=$((COUNTER_TOTAL+1))

    TMPTRTTSUM=$(echo 'scale=3;'$TMPTRTTSUM + $NEWRTTAVG|bc)
    TMP_DEV_RTT=$(echo 'scale=3;'$TMP_DEV_RTT + $STRD_DEV_RTT|bc)
    RTTSUM=$(echo 'scale=3;'$RTTSUM + $NEWRTTAVG|bc)
    TOTALSTRD_DEV_RTT=$(echo 'scale=3;'$TOTALSTRD_DEV_RTT + $STRD_DEV_RTT|bc)
    echo $COUNTER"\t"$NEWRTTAVG"\t"$STRD_DEV_RTT >> "RTT.dat"
    echo $COUNTER" | "$NEWRTTAVG" | "$STRD_DEV_RTT | column -t >> $FILENAME".log"
  done
  echo "\n" >> $FILENAME".log"
  echo "Machine $MACHINE_COUNTER | "$(echo 'scale=3;'$TMPTRTTSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TMP_DEV_RTT/$COUNTER|bc)" (deviation ms)" | column -t >> $FILENAME".log"
  echo "\n" >> $FILENAME".log"  
  COUNTER=0
  TMP_DEV_RTT=0
  TMPTRTTSUM=0
done

echo "Overall | "$(echo 'scale=3;'$RTTSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_RTT/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"


#BANDWIDTH analysis
NEWBWAVG=0
STRD_DEV_BW=0
TOTALSTRD_DEV_BW=0
BWSUM=0
COUNTER=0
MACHINE_COUNTER=0
COUNTER_TOTAL=0
TMPBWSUM=0
TMPBWDEV=0
echo "Doing Bandwidth..."
echo "\n\nBANDWIDTH\n----------------------------\n" >> $FILENAME".log"
#$1 contains the directory of all files used for performance
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu*")
do 
  MACHINE_COUNTER=$((MACHINE_COUNTER+1))
  echo "* MACHINE $MACHINE_COUNTER *" | column -t >> $FILENAME".log"
  echo "Iteration | SSRC | BW Avg | Deviation BW (Kbit/s)" | column -t >> $FILENAME".log"
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
      STRD_DEV_BW=$(cat $FILE_SSRC_CONMON_bitrate.txt|awk '{sum+=$2; sumsq+=$2*$2} END {print (sqrt(sumsq/NR - (sum/NR)**2)/2)}')
      NEWBWAVG=`echo $NEWBWAVG | tr ',' '.'`
      STRD_DEV_BW=`echo $STRD_DEV_BW | tr ',' '.'`
      COUNTER=$((COUNTER+1))
      COUNTER_TOTAL=$((COUNTER_TOTAL+1))

      TMPBWSUM=$(echo 'scale=3;'$TMPBWSUM + $NEWBWAVG|bc)
      TMPBWDEV=$(echo 'scale=3;'$TMPBWDEV + $STRD_DEV_BW|bc)
      BWSUM=$(echo 'scale=3;'$BWSUM + $NEWBWAVG|bc)
      TOTALSTRD_DEV_BW=$(echo 'scale=3;'$TOTALSTRD_DEV_BW + $STRD_DEV_BW|bc)
      echo $COUNTER"\t"$NEWBWAVG"\t"$STRD_DEV_BW >> "BW_DATA_$MACHINE_COUNTER.dat"
      echo $COUNTER" | " $SSRC" | "$NEWBWAVG" | "$STRD_DEV_BW | column -t >> $FILENAME".log"
      rm $FILE_SSRC_CONMON_bitrate.txt
    done
  done
  echo "\n" >> $FILENAME".log"
  echo "Machine $MACHINE_COUNTER | "$(echo 'scale=3;'$TMPBWSUM/$COUNTER|bc)" | "$(echo 'scale=3;'$TMPBWDEV/$COUNTER|bc) | column -t >> $FILENAME".log"
  echo "\n" >> $FILENAME".log"  
  COUNTER=0
  TMPBWSUM=0
  TMPBWDEV=0
done

echo "Overall | "$(echo 'scale=3;'$BWSUM/$COUNTER_TOTAL|bc)" | "$(echo 'scale=3;'$TOTALSTRD_DEV_BW/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"


#Tyding datafile

join -2 1 -2 1 BW_DATA_1.dat BW_DATA_2.dat > BW_DATA_t.dat
sed 1d BW_DATA_t.dat > BW_DATA.dat
rm BW_DATA_t.dat
#cat BW_DATA.dat

echo "Plotting bandwidth..."
# We are using bitrate.txt for the data
gnuplot << EOF
reset
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output '$1/output/mean_deviation_bw.pdf'
#unset key 
set ylabel "Observed rate [kbps]"

set xrange [ 0.00000 : 10.5000 ]
set yrange [ 0 : 2500 ]

set grid

#set title "Mean and deviation for bandwidth" font ",14"
set xlabel "Iterations"
plot "BW_DATA_1.dat" u (column(1)-0.1):2:3 with yerrorbars lt -1 pi -6 pt 7 lc 7 lw 5 ps 1.5 title "Machine A", \
"BW_DATA_2.dat" u (column(1)+0.1):2:3 with yerrorbars lt -1 pi -6 pt 7 lc 8 lw 5 ps 1.5 title "Machine B"

EOF

# Delay calculation
COUNTER_TOTAL=0
ONE=0
for FOLDER in $(find $1 -maxdepth 1 -mindepth 1 -name "*ubuntu3*")
do
  for FILE_RTP in $(find $FOLDER  -name "rtp*")
  do
    if [ "$ONE" -eq "0" ]
    then
      COUNTER_TOTAL=$((COUNTER_TOTAL+1))
      dir2=${FILE_RTP/lubuntu3/lubuntu4}"/"
      dir1=$(echo $FILE_RTP)"/"
      dir1=$(dirname $dir1)
      dir2=$(dirname $dir2)
      #echo $dir2
      #echo $dir1
      echo "Calculating delay for iteration $COUNTER_TOTAL"
      python diff.py $dir1"/" $dir2"/" $COUNTER_TOTAL $1
      echo "Plotting delay for iteration $COUNTER_TOTAL"
      ./delay_increase.sh $COUNTER_TOTAL $1
      ONE=1
    else
      ONE=0
    fi
  done
done


echo "Plotting all delay distribution iterations..."
mkdir -p $1/output/output_delay
#plotting bitrate.txt using gnuplot
gnuplot << EOF
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output "$1/output/output_delay/total_delay_distribution.pdf"
set origin 0,0
set size ratio 0.29
set key right top inside
set pointsize 2.5
unset key

set xlabel "Delay [ms]"
set ylabel "Packets"
set yrange [0:1]
#set xrange [0:500]
set grid
set style fill pattern 5
set xtics border out scale 0,0 mirror offset character 0, 0, 0
#set title "Delay distribution for all iterations" font ",14"

plot "$1/output/output_delay/distribution_delay_inc_1.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc -1, \
"$1/output/output_delay/distribution_delay_inc_2.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 1, \
"$1/output/output_delay/distribution_delay_inc_3.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 2, \
"$1/output/output_delay/distribution_delay_inc_4.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 3, \
"$1/output/output_delay/distribution_delay_inc_5.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 4, \
"$1/output/output_delay/distribution_delay_inc_6.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 5, \
"$1/output/output_delay/distribution_delay_inc_7.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 6, \
"$1/output/output_delay/distribution_delay_inc_8.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 7, \
"$1/output/output_delay/distribution_delay_inc_9.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 8, \
"$1/output/output_delay/distribution_delay_inc_10.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc 9
EOF

echo "Calculating delay average and deviation..."
# Calculate average and standard deviation for 

COUNTER_TOTAL=0
COUNTER1=0
COUNTER2=0
AVGDELAY=0
TOTALSTRD_DEV_DELAY=0
MACHINE_COUNT=1
TMPMACHINE1DELAY=0
TMPMACHINE1DELAYDEV=0
TMPMACHINE2DELAY=0
TMPMACHINE2DELAYDEV=0
echo "\n\nDELAY\n----------------------------\n" >> $FILENAME".log"
for FILE in $(find $1/output/output_delay  -name "delay_*.txt" | sort -n -t _ -k 3)
do
  #Convert points to commas for processing
  tr '.' ',' < $FILE > tmp.txt
  #echo $FILE
  NEWAVGDELAY=$(cat tmp.txt|awk '{sum+=$3} END { print "",(sum/NR)*1000}')
  STRD_DEV_DELAY=$(cat tmp.txt|awk '{sum+=$3; sumsq+=$3*$3} END {print ((sqrt(sumsq/NR - (sum/NR)**2)/2))*1000}')

  COUNTER_TOTAL=$((COUNTER_TOTAL+1))
  NEWAVGDELAY=`echo $NEWAVGDELAY | tr ',' '.'`
  STRD_DEV_DELAY=`echo $STRD_DEV_DELAY | tr ',' '.'`
  TOTALSTRD_DEV_DELAY=$(echo "scale=3;$TOTALSTRD_DEV_DELAY+$STRD_DEV_DELAY" | bc)
  AVGDELAY=$(echo "scale=3;$AVGDELAY + $NEWAVGDELAY" | bc)
  if [ $MACHINE_COUNT -eq "1" ]
  then
    COUNTER1=$((COUNTER1+1))
    echo $COUNTER1"\t"$NEWAVGDELAY"\t"$STRD_DEV_DELAY >> "machine1.dat"
    echo $COUNTER1" | "$NEWAVGDELAY" | "$STRD_DEV_DELAY | column -t >> "machine1.tmp"
    MACHINE_COUNT=$(($MACHINE_COUNT + 1))
    TMPMACHINE1DELAY=$(echo 'scale=3;'$TMPMACHINE1DELAY + $NEWAVGDELAY|bc)
    TMPMACHINE1DELAYDEV=$(echo 'scale=3;'$TMPMACHINE1DELAYDEV + $STRD_DEV_DELAY|bc)
  else
    COUNTER2=$((COUNTER2+1))
    echo $COUNTER1"\t"$NEWAVGDELAY"\t"$STRD_DEV_DELAY >> "machine2.dat"
    echo $COUNTER2" | "$NEWAVGDELAY" | "$STRD_DEV_DELAY | column -t >> "machine2.tmp"
    MACHINE_COUNT=$(($MACHINE_COUNT - 1))
    TMPMACHINE2DELAY=$(echo 'scale=3;'$TMPMACHINE2DELAY + $NEWAVGDELAY|bc)
    TMPMACHINE2DELAYDEV=$(echo 'scale=3;'$TMPMACHINE2DELAYDEV + $STRD_DEV_DELAY|bc)
  fi
done
echo "* MACHINE 1 *" >> $FILENAME".log"
echo "Iteration | Delay Avg | Deviation delay (ms)" | column -t >> $FILENAME".log"
cat machine1.tmp >> $FILENAME".log"
echo "Machine | "$(echo 'scale=3;'$TMPMACHINE1DELAY/$COUNTER1|bc)" | "$(echo 'scale=3;'$TMPMACHINE1DELAYDEV/$COUNTER1|bc) | column -t >> $FILENAME".log"
echo "\n" >> $FILENAME".log"
echo "\n* MACHINE 2 *" >> $FILENAME".log"
echo "Iteration | Delay Avg | Deviation delay (ms)" | column -t >> $FILENAME".log"
cat machine2.tmp >> $FILENAME".log"
echo "Machine | "$(echo 'scale=3;'$TMPMACHINE2DELAY/$COUNTER2|bc)" | "$(echo 'scale=3;'$TMPMACHINE2DELAYDEV/$COUNTER2|bc) | column -t >> $FILENAME".log"
echo "\n" >> $FILENAME".log"
echo "\nOverall | "$(echo 'scale=4;'$AVGDELAY/$COUNTER_TOTAL|bc)" | "$(echo 'scale=4;'$TOTALSTRD_DEV_DELAY/$COUNTER_TOTAL|bc) | column -t >> $FILENAME".log"

echo "Plotting delay average and deviation..."
# We are using bitrate.txt for the data
gnuplot << EOF
reset
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output '$1/output/output_delay/mean_deviation_delay.pdf'
#unset key 
set ylabel "Delay [ms]"

set xrange [ 0.00000 : 10.5000 ]
#set yrange [ 0 : 50 ]

set grid

#set title "Mean and deviation for delay" font ",14"
set xlabel "Iterations"
plot "machine1.dat" u (column(1)-0.1):2:3 with yerrorbars lt -1 pi -6 pt 7 lc 4 lw 5 ps 1.5 title "Machine A", \
"machine2.dat" u (column(1)+0.1):2:3 with yerrorbars lt -1 pi -6 pt 7 lc 6 lw 5 ps 1.5 title "Machine B"
EOF
rm machine1.dat
rm machine2.dat
rm machine2.tmp
rm machine1.tmp
rm tmp.txt

CALLS=0
COUNTER=0
# Log calls failed
for FILE in $(find $1 -name "out_*")
do
  CALLS=$((CALLS+1))
  COUNTER=$((COUNTER+1))
done
echo "\n\n\nCalls failed: "$(echo 'scale=4;'$CALLS/2|bc) | column -t >> $FILENAME".log"

echo "Done all"
rm PL_DATA_2.dat
rm PL_DATA_1.dat
rm BW_DATA_2.dat
rm BW_DATA_1.dat
rm BW_DATA.dat
rm CPU_MEM_DATA.dat
rm RTT.dat
rm SETUP_TIME.dat