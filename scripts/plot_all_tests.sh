#! /bin/sh
# Plot all

for FOLDER in $(find /Users/Albert/Desktop/MTesis/results/P2P -maxdepth 1 -mindepth 1 -name "p2p*")
do 
	echo "------ Plotting $FOLDER ------"
	./data_extraction.sh $FOLDER
done