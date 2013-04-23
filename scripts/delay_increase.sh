#! /bin/sh

#tr '.' ',' < delay_inc.txt > tmp.txt
mkdir -p output_delay
#plotting bitrate.txt using gnuplot
gnuplot << EOF
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output "$2/output/output_delay/delay_inc_$1.pdf"
set origin 0,0
set size ratio 0.29
set key right top inside
set pointsize 2.5
unset key

set xlabel "Delay [ms]"
set ylabel "Packets"
set yrange [0:1]
set xrange [0:1000]
set grid
set style fill pattern 5
set xtics border out scale 0,0 mirror offset character 0, 0, 0

set title "Delay distribution" font ",14"
plot "$2/output/output_delay/distribution_delay_inc_$1.txt" using 1:2 with linespoints lw 3 lt -1 pt 6 ps 1.5 lc -1
EOF
#rm delay_inc.txt
#rm tmp.txt