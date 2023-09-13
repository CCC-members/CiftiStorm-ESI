#!/bin/bash 

freesurfer_ws=$1
data_dir=$2
subject_name=$3

tittle="------Freesurfer-recon-all------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
export SUBJECTS_DIR=$freesurfer_ws
echo "-->> Freesurfer work dir: "$freesurfer_ws
echo "-->> Processing subject: "$subject_name
echo "-->> Processing recon_all"
T1w_file=$data_dir"/"$subject_name"/anat/"$subject_name"_T1w.nii.gz"
if test -f $T1w_file; then
  recon-all -i $T1w_file -sd $freesurfer_ws -s $subject_name -all -verbose
  echo "-->> Freesurfer process finished. subject: "$subject_name
else
  echo "The file: $T1w_file do not exist"
fi

