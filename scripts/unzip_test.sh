#! /bin/sh

for FILE in $(find $1 -name "*.tar")
do
	echo $FILE
	tar xopf $FILE
done

