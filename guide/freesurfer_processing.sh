#!/bin/bash 

tittle="------Executing Freesurfer multi process on Linux------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."

freesurfer_ws=$1
substr=$2
data_path=$3
ref_file=$4

echo ------------------------------------------------------------
echo "Input variables"
echo ------------------------------------------------------------
echo "Freesurfer Workspace: " $freesurfer_ws
echo "Data paht: " $data_path
echo "Subjects: "$substr
echo ------------------------------------------------------------

export SUBJECTS_DIR=$freesurfer_ws
subjects=()
read -a subjects <<< $substr
for subID in "${subjects[@]}"; do
 echo "Processing subject: "$subID
 file="${ref_file/SubID/"$subID"}"
 T1w_file=$data_path/$subID/$file
 recon-all -i $T1w_file -sd $freesurfer_ws -s $subID -all -verbose
done


echo "Process finished!!!"
