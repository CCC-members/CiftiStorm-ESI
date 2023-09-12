#!/bin/bash 
tittle="------Bet process for non-brain surfaces------"
echo ""
echo $tittle
echo ""
echo "->> Starting process..."

ciftify_path="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/realese_2/ciftify/"
bet_work_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/realese_2/non_brain/"
echo "->> bet work dir: "$bet_work_dir

for subject in "$ciftify_path"/*
do
  if [ -d "$subject" ]; then

	subject_dir=`dirname $subject`
	subject_name=`basename $subject`
	echo "-->> Processing subject: "$subject_name
 
  if [ -f $subject_dir"/"$subject_name"/T1w/T1w.nii.gz" ]; then
    mkdir $bet_work_dir"/"$subject_name
     bet $subject_dir"/"$subject_name"/T1w/T1w.nii.gz" $bet_work_dir"/"$subject_name"/"$subject_name -A -v
  fi
fi
done