#!/bin/bash 
tittle="------Anatomy Pipeline------"
echo ""
echo $tittle
echo ""
echo "->> Starting process..."

anat_path="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/"
echo "->> Anat Path: "$anat_path
freesurfer_path="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/derivatives/freesurfer/"
echo "->> Freesurfer OutPut Path: "$freesurfer_path
ciftify_work_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/derivatives/ciftify/"
echo "->> Ciftify OutPut Path: "$ciftify_path
bet_work_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/derivatives/FSL_Bet/"
echo "-->> FSL Bet output Path: "$bet_work_dir

export $freesurfer_path
# Running freesurfer
for subject in "$anat_path"/*
do
  if [ -d "$subject" ]; then

    	subject_dir=`dirname $subject`
    	subject_name=`basename $subject`
    	#echo $subject_name
    	T1w_file=$subject"/anat/"$subject_name"_T1w.nii.gz"
    	
    	if [ -f "$T1w_file" ]; then
        		echo "$T1w_file exist"
    		recon-all -i $T1w_file -sd $freesurfer_path -s $subject_name -all > $freesurfer_path"/$subject_name.txt"
    	else
    		echo "->> Error:The subject: "$subject_name". Don't have any T1w."
    	fi    
  fi
done
wait
# Running ciftify
for subject_freesf in "$freesurfer_path"/*
do
	if [ -d "$subject_freesf" ]; then
		subject_dir=`dirname $subject_freesf`
		subject_name=`basename $subject_freesf`
		ciftify_recon_all --verbose --surf-reg FS --resample-to-T1w32k --fs-subjects-dir $freesurfer_path --ciftify-work-dir $ciftify_work_dir $subject_name
	fi
done
wait
# Running ciftify qc
for subject in "$ciftify_work_dir"/*
do
  if [ -d "$subject" ]; then

	subject_dir=`dirname $subject`
	subject_name=`basename $subject`
	echo "-->> Processing subject: "$subject_name
	cifti_vis_recon_all subject --ciftify-work-dir=$ciftify_work_dir $subject_name
  fi
done
wait
# Running FSL bet
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
wait
echo ""
echo "Done.."
echo ""
