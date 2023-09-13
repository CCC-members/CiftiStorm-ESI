#!/bin/bash 
tittle="------Cifti-vis-recon-all------"
echo ""
echo $tittle
echo ""
echo "->> Starting process..."

ciftify_work_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/run/ciftify/"
echo "->> ciftify work dir: "$ciftify_work_dir

for subject in "$ciftify_work_dir"/*
do
  if [ -d "$subject" ]; then

	subject_dir=`dirname $subject`
	subject_name=`basename $subject`
	echo "-->> Processing subject: "$subject_name
	cifti_vis_recon_all subject --ciftify-work-dir=$ciftify_work_dir $subject_name
  fi
done
