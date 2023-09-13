#!/bin/bash 

fs_subjects_dir=$1
ciftify_work_dir=$2
subject_name=$3

tittle="------Ciftify-recon-all------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
echo "-->> Processing subject: "$subject_name
echo "-->> Processing ciftify_recon_all"
ciftify_recon_all --verbose --surf-reg FS --resample-to-T1w32k --fs-subjects-dir $fs_subjects_dir --ciftify-work-dir $ciftify_work_dir $subject_name
echo "-->> Processing ciftify_vis_recon_all"
cifti_vis_recon_all subject --ciftify-work-dir=$ciftify_work_dir $subject_name
echo "-->> Ciftify process finished. subject: "$subject_name
