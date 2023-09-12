#!/bin/bash 
tittle="------Anatomy Pipeline------"
echo ""
echo $tittle
echo " "
echo "->> Starting process..."

anat_path="/home/ariosky/Raw_Data"
echo "->> Anat Path: "$anat_path
freesurfer_path="/home/ariosky/freesurfer"
echo "->> Freesurfer OutPut Path: "$freesurfer_path
ciftify_work_dir="/home/ariosky/ciftify_work_dir"
echo "->> Ciftify OutPut Path: "$ciftify_path

export $freesurfer_path

for subject in "$anat_path"/*
do
  if [ -d "$subject" ]; then

	subject_dir=`dirname $subject`
	subject_name=`basename $subject`
	#echo $subject_name
	T1w_VNavNorm=$subject"/anat/"$subject_name"_acq-VNavNorm_T1w.nii.gz"
	T1w_HCP=$subject"/anat/"$subject_name"_acq-HCP_T1w.nii.gz"
	
	if [ -f "$T1w_VNavNorm" ]; then
    		echo "$T1w_VNavNorm exist"
		recon-all -i $T1w_VNavNorm -sd $freesurfer_path -s $subject_name -all > $freesurfer_path"/$subject_name.txt" &
	elif [ -f "$T1w_HCP" ]; then
		echo "$T1w_HCP exist"
		recon-all -i $T1w_HCP -sd $freesurfer_path -s $subject_name -all > $freesurfer_path"/$subject_name.txt" &
	else
		echo "->> Error:The subject: "$subject_name". Don't have any T1w."
	fi
	#echo $T1w
	
      #echo $subject
  fi
done

wait

for subject_freesf in "$freesurfer_path"/*
do
	if [ -d "$subject_freesf" ]; then
		subject_dir=`dirname $subject_freesf`
		subject_name=`basename $subject_freesf`
		ciftify_recon_all --verbose --surf-reg FS --resample-to-T1w32k --fs-subjects-dir $freesurfer_path --ciftify-work-dir $ciftify_work_dir $subject_name
	fi
done

echo ""
echo "Done.."
echo ""
