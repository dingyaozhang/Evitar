#!/bin/bash
#$ -cwd
work_path=$(dirname $(readlink -f $0))
while read -r line; do
	g=$(echo $line | cut -d "," -f 1 )
	t=$(echo $line | cut -d "," -f 2 )
	"$work_path/RNAhybrid" -c -s 3utr_human ${g} ${t}
done < $1