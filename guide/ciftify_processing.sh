#!/bin/bash 

tittle="------Executing Ciftify multi process on Linux------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."

freesurfer_ws=$1
ciftify_ws=$2
substr=$3
ciftify_vis=$4

echo ------------------------------------------------------------
echo "Input variables"
echo ------------------------------------------------------------
echo "Freesurfer Workspace: " $freesurfer_ws
echo "Ciftify Workspace: " $ciftify_ws
echo "Subjects: "$substr
echo ------------------------------------------------------------

subjects=()
read -a subjects <<< $substr
for subID in "${subjects[@]}"; do
 echo "Processing subject: "$subID
 echo "-->> Processing ciftify_recon_all"
 ciftify_recon_all --verbose --surf-reg FS --resample-to-T1w32k --fs-subjects-dir $freesurfer_ws --ciftify-work-dir $ciftify_ws $subID
 if [ "$ciftify_vis" = 1 ]; then
   echo "-->> Processing ciftify_vis_recon_all"
   cifti_vis_recon_all subject --ciftify-work-dir=$ciftify_ws $subID
 fi
 echo "-->> Process finished. Subject: "$subID
done

echo "Process finished!!!"
