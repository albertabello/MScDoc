#! /bin/sh
./perinst.awk $1.txt > $1_bitrate.txt

# removing first line from bitrate.txt
mv $1_bitrate.txt $1_bitrate.tmp
sed 1d $1_bitrate.tmp > $1_bitrate.txt
rm $1_bitrate.tmp


#If we have Stats export file
tr '\r' '\n' < $2.txt > tmp.file
mv tmp.file $2_noCR.txt
./perinst2.awk $2_noCR.txt > $2_bitrate.txt
rm $2_noCR.txt

mv $2_bitrate.txt $2_bitrate.tmp
sed 1d $2_bitrate.tmp > $2_bitrate.txt
rm $2_bitrate.tmp

#If we have Stats export file
tr '\r' '\n' < $3.txt > tmp.file
mv tmp.file $3_noCR.txt
./perinst2.awk $3_noCR.txt > $3_bitrate.txt
rm $3_noCR.txt

mv $3_bitrate.txt $3_bitrate.tmp
sed 1d $3_bitrate.tmp > $3_bitrate.txt
rm $3_bitrate.tmp


#plotting bitrate.txt using gnuplot
gnuplot << EOF
name=system("echo $2 $3 $1") 
time=system("date +%Y%m%d_%H%M%S")
set terminal pdf color enhanced rounded size 12,4 fsize 14
set output name."-".time.".pdf"
set origin 0,0
set size ratio 0.29
set key right top inside
set pointsize 2.5

set xlabel "Time [s]"
set ylabel "Observed rate [kbps]"
set grid
set style fill pattern 5
set xtics border out scale 0,0 mirror offset character 0, 0, 0
set timefmt "%s"
set format x "%H:%M:%S"
set xdata time

plot "$1_bitrate.txt" using 1:2 title "ConMon" with linespoints lw 3 lt -1 pt 6 pi 31 ps 1.5 lc 0,\
"$2_bitrate.txt" using 1:2 title "$2" with linespoints lw 3 lt -1 pt 7 pi 30 ps 1.5 lc -1,\
"$3_bitrate.txt" using 1:2 title "$3" with linespoints lw 3 lt -1 pt 8 pi 29 ps 1.5 lc 1
#plot "$2.txt" using 1:2 title "stats" with linespoints lw 3 lt -1 pi 30 pt 6 ps 1.5 lc 3
EOF
rm $1_bitrate.txt
rm $2_bitrate.txt
rm $3_bitrate.txt