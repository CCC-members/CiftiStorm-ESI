#!/bin/bash 

helpFunction()
{
   echo ""
   echo "Usage: $0 -i raw_data_path -s subject_name -o study_path"
   echo -e "\t-i Subjects direction folder"
   echo -e "\t-s Subject name or subject ID"
   echo -e "\t-o Output folder"
   echo -e "\t-h Help option"
   exit 1 # Exit script after printing help
}

while getopts "i:s:o:" opt
do
   case "$opt" in
      i) raw_data_path="$OPTARG" ;;
      s) subject_name="$OPTARG" ;;
      o) subject_name="$OPTARG" ;;
      ?) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$raw_data_path" ] || [ -z "$subject_name" ] || [ -z "$subject_name" ]
then
	echo ""
	echo "Some or all of the parameters are empty";
	helpFunction
fi

tittle="------DTI process Pipeline------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
echo $raw_data_path
echo "-------------------------------------------------------"
echo "-->> Preparing variables......"
raw_data_path="/data3_260T/data/CCLAB_DATASETS/CMI/CMI-HBN_data/HBN_MRI_R4"
echo "-->> Raw Data Path: "$raw_data_path
output_path="/home/ariosky/DTI_Study"
echo "-->> OutPut Folder: "$output_path


subject_id="sub-NDARAD615WLJ"
echo "-->> Preparing subject envairoment for: "$subject_id
subject_output_path=$output_path"/"$subject_id

if [ ! -d $subject_output_path ] 
then
    echo "-->> Creating subject folder for: "$subject_id
    mkdir -p $subject_output_path
fi 

dwi_file=$raw_data_path"/"$subject_id"/dwi/"$subject_id"_acq-64dir_dwi.nii.gz"
nodif_file=$subject_output_path"/nodif"

fslroi $dwi_file $nodif_file 0 1

acqparam_file=$subject_output_path"/acqparams.txt"
echo "-->> Creating acqparams file"
#   The first three elements of each line comprise a vector that specifies the direction of the phase encoding.
#   The non-zero number in the second column means that is along the y-direction. 
#   A -1 means that k-space was traversed Anterior?Posterior and a 1 that it was traversed Posterior?Anterior. 
#   The final column specifies the "total readout time"
#   if you don't have the total readout time, you can obtain this value fallow this: https://lcni.uoregon.edu/kb-articles/kb-0003
printf "0 -1 0 0.0401697\n0 1 0 0.0401697" > $acqparam_file

dwi_ap_file=$raw_data_path"/"$subject_id"/fmap/"$subject_id"_dir-AP_acq-dwi_epi.nii.gz"
dwi_pa_file=$raw_data_path"/"$subject_id"/fmap/"$subject_id"_dir-PA_acq-dwi_epi.nii.gz"

echo "-->> Merging AP and PA file (OutPut: AP_PA_b0.nii.gz )"
fslmerge \
-t $subject_output_path"/"$subject_id"_AP_PA_b0" \
$dwi_ap_file $dwi_pa_file

AP_PA_b0_file=$subject_output_path"/"$subject_id"_AP_PA_b0.nii.gz"


# TopUp process: Correct fo susceptibility distortions using merged B0 images with oposite phase encoding directions
echo "-->> Preparing Topup"
TopUp_path=$subject_output_path"/TopUp"
mkdir -p $TopUp_path
b02b0_file=$TopUp_path"/b02b0.cnf"
topup_AP_PA_b0_file=$TopUp_path"/"$subject_id"_topup_AP_PA_b0"
topup_AP_PA_b0_iout_file=$TopUp_path"/"$subject_id"_topup_AP_PA_b0_iout"
topup_AP_PA_b0_fout_file=$TopUp_path"/"$subject_id"_topup_AP_PA_b0_fout"
echo "-->> Running Topup"
topup \
--imain=$AP_PA_b0_file \
--datain=$acqparam_file \
--config="b02b0.cnf" \
--out=$topup_AP_PA_b0_file \
--iout=$topup_AP_PA_b0_iout_file \
--fout=$topup_AP_PA_b0_fout_file \
--verbose

echo "-->> Applying Topup"
applay_topup_path=$subject_output_path"/ApplyTopup"
mkdir -p $applay_topup_path

#Applying topup
applytopup \
--imain=$dwi_ap_file,$dwi_pa_file \
--topup=$topup_AP_PA_b0_file \
--datain=$acqparam_file \
--inindex=1,2 \
--out=$applay_topup_path"/hifi_nodif_qc"
           
hifi_nodif_file_qc=$applay_topup_path"/hifi_nodif_qc.nii.gz"

# EDDY - Correcting for Eddy Currents
echo "-->> Running EDDY"
echo "-->> Preparing properties"
eddy_path=$subject_output_path"/EDDY"
mkdir -p $eddy_path

hifi_nodif_file=$eddy_path"/"$subject_id"_hifi_nodif"
fslmaths $topup_AP_PA_b0_iout_file".nii.gz" -Tmean $hifi_nodif_file


hifi_nodif_brain_file=$eddy_path"/"$subject_id"_hifi_nodif_brain"
bet $hifi_nodif_file".nii.gz" $hifi_nodif_brain_file -m -f "0.2"

# Creating the index.txt file
echo "-->> Creating the index file"

echo "-->> Obtaining DWI_file Info"
fslinfo $dwi_file
index_file=$eddy_path"/index.txt"

no_dir=`fslval $dwi_file dim4`
echo "Geting directions number"
index_vector=""
for (( c=1; c<$no_dir; c++ ))
do
    index_vector+="1\n"
done
index_vector+="1"

printf "$index_vector" > $index_file

# input
hifi_nodif_brain_mask_file=$eddy_path"/"$subject_id"_hifi_nodif_brain_mask.nii.gz"
dwi_bvec_file=$raw_data_path"/"$subject_id"/dwi/"$subject_id"_acq-64dir_dwi.bvec"
dwi_bval_file=$raw_data_path"/"$subject_id"/dwi/"$subject_id"_acq-64dir_dwi.bval"
dwi_file_name=$raw_data_path"/"$subject_id"/dwi/"$subject_id"_acq-64dir_dwi"
#Output
eddy_unwarped_images_path=$eddy_path"/eddy_unwarped_images"
mkdir $eddy_unwarped_images_path


echo "-->> Running Eddy with the fallowing params"
echo "--imain="$dwi_file_name
echo "--mask="$hifi_nodif_brain_mask_file
echo "--index="$index_file 
echo "--acqp="$acqparam_file
echo "--bvecs="$dwi_bvec_file
echo "--bvals="$dwi_bval_file 
echo "--topup="$topup_AP_PA_b0_file 

# --fwhm=0 and --flm=quadratic specify that no smoothing should be applied to the data and that we assume a quadratic model for the EC-fields. 
#   These are our current recommendations and you are unlikely to ever have to use any other settings.
eddy_openmp \
--imain=$dwi_file_name \
--mask=$hifi_nodif_brain_mask_file \
--index=$index_file \
--acqp=$acqparam_file \
--bvecs=$dwi_bvec_file \
--bvals=$dwi_bval_file \
--topup=$topup_AP_PA_b0_file \
--fwhm=0 \
--flm=quadratic \
--out=$eddy_unwarped_images_path \
--data_is_shelled \
--verbose


# Computing difusion tensor fitting
echo "-->> Computing difusion tensor fitting"
dti_path=$subject_output_path"/DTI"
mkdir $dti_path

eddy_unwarped_images_file=$eddy_path"/eddy_unwarped_images.nii.gz"
eddy_rotated_bvecs_file=$eddy_path"/eddy_unwarped_images.eddy_rotated_bvecs"
dtifit --data=$eddy_unwarped_images \
--mask=$hifi_nodif_brain_mask_file \
--bvecs=$eddy_rotated_bvecs_file \
--bvals=$dwi_bval_file \
--out=$dti_path




echo "-->> Done!!!"












