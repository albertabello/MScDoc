#! /bin/sh
tr '\r' '\n' < $1.txt > tmp.file
mv tmp.file $1_noCR.txt
./perinst2.awk $1_noCR.txt > $1_bitrate.txt
rm $1_noCR.txt

mv $1_bitrate.txt $1_bitrate.tmp
sed 1d $1_bitrate.tmp > $1_bitrate.txt
rm $1_bitrate.tmp

# We are using bitrate.txt for the data
gnuplot << EOF
reset
set terminal pdf color enhanced rounded size 12,4 fsize 12
#unset key # Removes legend of the plot

set timefmt "%s"
set format x "%H:%M:%S"
set xdata time
name=system("echo $1") 
time=system("date +%Y%m%d_%H%M%S")
set output name."-".time."-minmaxmean.pdf"

# Retrieve statistical properties
plot '$1_bitrate.txt' u 1:2 title "Stream" 
min_y = GPVAL_DATA_Y_MIN
max_y = GPVAL_DATA_Y_MAX
min_x = GPVAL_DATA_X_MIN
max_x = GPVAL_DATA_X_MAX

set yrange [min_y:max_y+500]

f(x) = mean_y
fit f(x) '$1_bitrate.txt' u 1:2 via mean_y

set xlabel "Time [s]"
set ylabel "Observed rate [kbps]"
set timefmt "%s"
set format x "%H:%M:%S"
set xdata time
# Plotting the minimum and maximum ranges with a shaded background
#set label 1 gprintf("Minimum = %g", min_y) at (min_x+max_x)/2, max_y+200
set label 2 gprintf("Maximum = %g kbps", max_y) at (min_x+max_x)/2, max_y+200
set label 3 gprintf("Mean = %g kbps", mean_y) at (min_x+max_x)/2, max_y+100
plot min_y with filledcurves y1=mean_y title "Min" lt 1 lc rgb "#bbbbdd", \
max_y with filledcurves y1=mean_y title "Mean" lt 1 lc rgb "#bbddbb", \
'$1_bitrate.txt' u 1:2 title "Stream" w p pt 7 lt 1 ps 1
EOF
rm $1_bitrate.txt