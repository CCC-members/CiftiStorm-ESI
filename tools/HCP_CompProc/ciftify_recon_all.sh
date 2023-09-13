#!/bin/bash 
tittle="------Cifti-recon-all------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."

fs_subjects_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/realese_2/freesurfer/"
ciftify_work_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/realese_2/ciftify/"
echo "-->> ciftify work dir: "$ciftify_work_dir

for subject in "$fs_subjects_dir"/*
do
  if [ -d "$subject" ]; then

	subject_dir=`dirname $subject`
	subject_name=`basename $subject`
	echo "-->> Processing subject: "$subject_name
  echo "-->> Processing ciftify_recon_all"
  ciftify_recon_all --verbose --surf-reg FS --resample-to-T1w32k --fs-subjects-dir $fs_subjects_dir --ciftify-work-dir $ciftify_work_dir $subject_name
	echo "-->> Processing ciftify_vis_recon_all"
  cifti_vis_recon_all subject --ciftify-work-dir=$ciftify_work_dir $subject_name
  echo "-->> Ciftify process finished. subject: "$subject_name
  fi
done
echo "-->> Ciftify process completed."