#!/bin/bash
trap 'echo "# $BASH_COMMAND"' DEBUG

. _recycle_bin.sh

mkdir -p test
cd test

for i in $(seq 1 10)
do
	echo "This is a dummy file" > file_$i
done

ls


del -h

del file_1 file_2 file_3

ls

del -l3

del -u2

del -l3

ls


del file_*

del -l10

del -u8

ls

del -l8

cd ..

echo "finished tests"
