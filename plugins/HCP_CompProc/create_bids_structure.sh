#!/bin/bash 
tittle="------Modify structure to BIDS Format------"
echo ""
echo $tittle
echo ""
echo "->> Starting process..."

data_set_path="/data3_260T/data/CCLAB_DATASETS/PreventAD/openpreventad"
new_data_set_path="/data3_260T/data/CCLAB_DATASETS/PreventAD/openpreventad_bids"
echo "->> DataSet Path: "$data_set_path

for subject in "$data_set_path"/*
do
  if [ -d "$subject" ]; then
	subject_dir=`dirname $subject`
	subject_name=`basename $subject`
	new_subject_path=$new_data_set_path"/sub-"$subject_name

	mkdir $new_subject_path
	find $subject -iname "candidate.json" -exec cp {} $new_subject_path \;
	
	for PRE in "$subject"/*
	do
  		if [ -d "$PRE" ]; then
			PRE_dir=`dirname $PRE`
			PRE_name=`basename $PRE`
			new_PRE=$new_subject_path"/"$PRE_name
			mkdir $new_PRE
			find $PRE -iname "session.json" -exec cp {} $new_PRE \;
			
			anat=$new_PRE"/anat"
			asl=$new_PRE"/asl"
			fmap=$new_PRE"/fmap"
			func=$new_PRE"/func"
			dwi=$new_PRE"/dwi"
			flair=$new_PRE"/flair"
			#creating anat folder and moving files
			mkdir $anat
			find $PRE -iname "*t1w*" -exec cp {} $anat \;
			find $PRE -iname "*T2*" -exec cp {} $anat \;
			#creating asl folder and moving files
			mkdir $asl 
			find $PRE -iname "*asl*" -exec cp {} $asl \;
			
			#creating fmap folder and moving files
			mkdir $fmap
			find $PRE -iname "*fieldmap*" -exec cp {} $fmap \;
			#creating func folder and moving files
			mkdir $func
			find $PRE -iname "*task*" -exec cp {} $func \;			
			find $PRE -iname "*bold*" -exec cp {} $func \;
			#creating dwi folder and moving files
			mkdir $dwi
			find $PRE -iname "*dwi*" -exec cp {} $dwi \;
			#creating flair folder and moving files
			mkdir $flair
			find $PRE -iname "*flair*" -exec cp {} $flair \;
  		fi
	done	
  fi
done
