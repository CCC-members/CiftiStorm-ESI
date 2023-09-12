#!/bin/bash 

ciftify_ws=$1
bet_ws=$2
subject_name=$3

tittle="------Freesurfer-recon-all------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
echo "-->> Ciftfy workspace: "$ciftify_ws
echo "-->> Bet workspace: "$bet_ws
echo "-->> Processing subject: "$subject_name
echo "-->> Processing bet"
mkdir $bet_ws"/"$subject_name"/"
bet $ciftify_ws"/"$subject_name"/T1w/T1w.nii.gz" $bet_ws"/"$subject_name"/"$subject_name -A -v
echo "-->> Bet process finished. subject: "$subject_name

