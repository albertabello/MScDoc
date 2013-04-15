#! /bin/sh

#plotting bitrate.txt using gnuplot
gnuplot << EOF
name=system("echo $1") 
time=system("date +%Y%m%d_%H%M%S")
set terminal pdf color enhanced rounded size 12,4 fsize 10
set output name.".pdf"
set origin 0,0
set size ratio 0.29
set key right top inside
set pointsize 2.5

set xlabel "Time [s]"
set ylabel "Usage [%]"
set grid
set style fill pattern 5
set xtics border out scale 0,0 mirror offset character 0, 0, 0
set timefmt "%s"
set format x "%H:%M:%S"
set xdata time

plot "$1.txt" using 1:3 title "CPU" with linespoints lw 3 lt -1 pt 6 pi 31 ps 1.5 lc 0,\
"$1.txt" using 1:2 title "Memory" with linespoints lw 3 lt -1 pt 7 pi 30 ps 1.5 lc -1
EOF