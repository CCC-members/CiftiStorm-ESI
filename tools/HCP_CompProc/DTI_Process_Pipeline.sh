#!/bin/bash 

# example call
# dwi_dir="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/non-defeced/"
# sub_ID="sub-MC0000005"
# dwi_file=${dwi_dir}/${sub_ID}/dwi/sub-MC0000005_run-01_dwi.nii.gz
# bval_file=${dwi_dir}/${sub_ID}/dwi/sub-MC0000005_run-01_dwi.bval
# bvect_file=${dwi_dir}/${sub_ID}/dwi/sub-MC0000005_run-01_dwi.bvect
# b0_file=${dwi_dir}/${sub_ID}/fmap/sub-MC0000005_run-01_fmap.nii.gz
# ./DTI_Process_Pipeline.sh \
# --dwi /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/non-defeced/sub-MC0000005/dwi/sub-MC0000005_run-01_dwi.nii.gz \
# --bval /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/non-defeced/sub-MC0000005/dwi/sub-MC0000005_run-01_dwi.bval \
# --bvec /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/non-defeced/sub-MC0000005/dwi/sub-MC0000005_run-01_dwi.bvec \
# --b0 /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOKSY/non-defeced/sub-MC0000005/fmap/sub-MC0000005_run-01_fmap.nii.gz \
# --sub sub-MC0000005 \
# --out /home/ariosky/DWIstudy

#
#./DTI_Process_Pipeline.sh 
#--dwi /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/non-defeced/sub-MC0000010/dwi/sub-MC0000010_run-01_dwi.nii.gz 
#--bval /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/non-defeced/sub-MC0000010/dwi/sub-MC0000010_run-01_dwi.bval 
#--bvec /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/non-defeced/sub-MC0000010/dwi/sub-MC0000010_run-01_dwi.bvec 
#--b0 /data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/non-defeced/sub-MC0000010/fmap/sub-MC0000010_run-01_fmap.nii.gz --sub sub-MC0000010 
#--out /home/ariosky/DWIstudy

helpFunction()
{
   echo ""
   echo "Usage: $0 --dwi dwi_file --bval bval_file --bvec bvec_file --b0 b0_file --sub Subject_name --out study_path"
   echo "OR"
   echo "Usage: $0 --dwi dwi_file --bval bval_file --bvec bvec_file --fmap1 fmap1_file --fmap2 fmap2_file --sub subject_id --out study_path"
   echo -e "\t--dwi Subjects dwi file"
   echo -e "\t--bval Subject bval file"
   echo -e "\t--bvec Subject bval file"
   echo -e "\t--fmap1 dir-fmap1"
   echo -e "\t--fmap2 dir-fmap2"
   echo -e "\t--b0 Oposite phase encoding b0 volume"
   echo -e "\t--out Output folder"
   echo -e "\t--sub Subject ID or name"
   echo -e "\t-h Help option"
   exit 1 # Exit script after printing help
}

# Process command line options

SHORTOPTS="daefmbsoh:"
LONGOPTS="dwi:,dwi2:,bval:,bvec:,fmap1:,fmap2:,b0:,sub:,out:,help:"

ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS -- "$@" )

eval set -- "$ARGS"

while [ $# -gt 0 ]
do
  case "$1" in
      -d|--dwi) dwi_file="$2";;
      -c|--dwi2) dwi2_file="$2";;
	    -a|--bval) bval_file="$2";;
	    -e|--bvec) bvec_file="$2";;
	    -f|--fmap1) fmap1_file="$2";;
	    -m|--fmap2) fmap1_file="$2";;
      -b|--b0) b0_file="$2";;
      -s|--sub) subject_id="$2";;
      -o|--out) study_path="$2";;
      -h|--help) helpFunction ;; # Print helpFunction in case parameter is non-existent
      --) shift
       break
       ;;
      -*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
   esac
   shift
done
echo "-->> "$dwi_file
# Print helpFunction in case any of the parameters are empty
# required parameters
if [ -z "$dwi_file" ] || [ -z "$bval_file" ]  || [ -z "$bvec_file" ] || [ -z "$subject_id" ] || [ -z "$study_path" ]; then
	echo ""
	echo "Some or all of the parameters are empty";
	helpFunction
fi
# optional parameters b0 or fieldmap: they will be used in different 
if [ ! -z "$b0_file" ]; then
  if [ -z "$b0_file" ] && [ -z "$ap_file" ]; then
  	echo "";
  	echo "Do not input b0 and fieldmap files simultaneously, they correspond to different preprocessing pipelines: b0 (TOPUP pipeline) and fieldmaps (FUGUE pipeline)" ;
  	helpFunction
  fi
  if [ -z "$b0_file" ] && [ -z "$pa_file" ]; then
  	echo "";
  	echo "Do not input b0 and fieldmap files simultaneously, they correspond to different preprocessing pipelines: b0 (TOPUP pipeline) and fieldmaps (FUGUE pipeline)" ;
  	helpFunction
  fi
fi



tittle="------DWI process Pipeline------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
echo "========================================================"
echo "-->> Input variables......"
echo "-->>      DWI file: "$dwi_file
echo "-->>     Bval file: "$bval_file
echo "-->>     Bvec file: "$bvec_file

# Checking optional parameters
if [ ! -z "$dwi2_file" ]; then
echo "-->>     DWI2 file: "$dwi2_file
fi
if [ ! -z "$b0_file" ]; then
echo "-->>       B0 file: "$b0_file
fi
if [ ! -z "$ap_file" ]; then
echo "-->>       AP file: "$ap_file
fi
if [ ! -z "$ap_file" ]; then
echo "-->>       PA file: "$pa_file
fi

echo "-->> OutPut Folder: "$study_path
echo "-->>       Subject: "$subject_id

# check if the input parameters are correct

if [ ! -f "$dwi_file" ]; then
 echo "-->> Error: File <dwi_file:"$dwi_file"> DOES NOT exists."
 exit
fi
if [ ! -f "$bval_file" ]; then
 echo "-->> Error: File <bval_file:"$bval_file"> DOES NOT exists."
 exit
fi
if [ ! -f "$bvec_file" ]; then
 echo "-->> Error: File <bvec_file:"$bvec_file"> DOES NOT exists."
 exit
fi
#subject_raw_path=$raw_data_path"/"$subject_id
#if [ ! -d "$subject_raw_path" ]; then
# echo "-->> Error: Directory <"$subject_raw_path"> DOES NOT exists."
# exit
#fi
if [ ! -d "$study_path" ]; then
 echo "-->> Error: Directory <"$study_path"> DOES NOT exists."
 exit
fi
if [ "$b0_file" ]; then
  if [ -z "$b0_file" ] && [ ! -f "$b0_file" ]; then
   echo "-->> Error: File <b0_file:"$b0_file"> DOES NOT exists."
   exit
  fi
fi
if [ "$ap_file" ]; then
  if [ -z "$ap_file" ] && [ ! -f "$ap_file" ]; then
   echo "-->> Error: File <ap_file:"$ap_file"> DOES NOT exists."
   exit
  fi
fi
if [ "$pa_file" ]; then
  if [ -z "$pa_file" ] && [ ! -f "$pa_file" ]; then
   echo "-->> Error: File <pa_file:"$pa_file"> DOES NOT exists."
   exit
  fi
fi
echo "--------------------------------------------------------"
echo "-->> Preparing subject enviroment for: "$subject_id
subject_path=$study_path"/"$subject_id
dtifit_nonprocc_path=$subject_path"/dtifit_nonprocc"
b0norm_path=$subject_path"/b0norm"
b0norm_dtifit_path=$b0norm_path"/dtifit"
topup_path=$subject_path"/topup"
topup_dtifit_path=$topup_path"/dtifit"
eddy_path=$subject_path"/eddy"
eddy_dtifit_path=$eddy_path"/dtifit"
gradnonlin_path=$subject_path"/gradnonlin"
gradnonlin_dtifit_path=$gradnonlin_path"/dtifit"
regist_path=$subject_path"/regist"
dtifit_procc_path=$subject_path"/dtifit_procc"
bedpostx_path=$subject_path"/bedpostx"
probtrackx_path=$subject_path"/probtrackx" 
if [ ! -d $subject_path ]; then
    echo "-->> Creating folder structure for: "$subject_id
    mkdir -p $subject_path
    #    
    mkdir -p $dtifit_nonprocc_path
    #   
    mkdir -p $b0norm_path
    #
    mkdir -p $b0norm_dtifit_path
    #    
    mkdir -p $topup_path
    #
    mkdir -p $topup_dtifit_path
    #    
    mkdir -p $eddy_path
    #
    mkdir -p $eddy_dtifit_path
    #    
    mkdir -p $gradnonlin_path
    #
    mkdir -p $gradnonlin_dtifit_path
    #    
    mkdir -p $regist_path
    #    
    mkdir -p $dtifit_procc_path
    #    
    mkdir -p $bedpostx_path
    #    
    mkdir -p $probtrackx_path
fi 

# Process for just one DWI AP File
if [ "$dwi_file" ] && [ -z "$ap_file" ] && [ -z "$pa_file" ]; then
  # Checking structure of input data
  
  echo "-->> DWI file information"
  fslinfo $dwi_file 
  echo "-->> DWI 2 file information"
  fslinfo $dwi2_file 
  
  # Ordering slices
  tmp_folder=$subject_path"/temp"
  mkdir $tmp_folder
  slices_d1=$tmp_folder"/slices_d1"
  mkdir $slices_d1  
  slices_d2=$tmp_folder"/slices_d2"
  mkdir $slices_d2
  merge_path=$tmp_folder"/merge_processig"
  mkdir $merge_path
  
  # Getting the volumn part and split by slices
  nodif_file_1=$slices_d1"/"$subject_id"_nodif_1"
  fslroi $dwi_file $nodif_file_1 0 1
  fslslice $nodif_file_1
  no_slices=`fslval $nodif_file_1 dim3`  
  nodif_file_2=$slices_d2"/"$subject_id"_nodif_2"
  fslroi $dwi2_file $nodif_file_2 0 1
  fslslice $nodif_file_2
  for (( c=0; c<$no_slices; c++ ))
  do
    slice_d1=$nodif_file_1"_slice_00"
    slice_d2=$nodif_file_2"_slice_00"
      if [[ $c -lt 10 ]] ; then
        slice_d1+="0"$c".nii.gz"
        slice_d2+="0"$c".nii.gz"                
      else
        slice_d1+=$c".nii.gz"
        slice_d2+=$c".nii.gz"
      fi 
      merged_volumn=$merge_path"/"$subject_id"_merged_volumn_"$c".nii.gz"  
        echo "-->> Merging slices:" 
        echo $slice_d1
        echo $slice_d2    
      if [[ $c -eq 0 ]] ; then                        
        fslmerge \
            -z $merge_path"/"$subject_id"_merged_volumn_"$c \
            $slice_d1 $slice_d2            
      else
        fslmerge \
            -z $merge_path"/"$subject_id"_merged_volumn_"$c \
           $merge_path"/"$subject_id"_merged_volumn_"$((c-1))".nii.gz" $slice_d1 $slice_d2          
      fi
      
  done  
  exit
  # Merging volums
  echo "-->> Merging volums file"
  fslmerge \
  -t $b0norm_path"/"$subject_id"_volum_merged" \
  $nodif_file_1 $nodif_file_2
  volum_merged=$b0norm_path"/"$subject_id"_volum_merged.nii.gz"
  exit
  
  echo "-->> Creating acqparams file"
  acqparam_file=$subject_path"/acqparams.txt"
  printf "0 -1 0 0.01247" > $acqparam_file
  
  echo "-->> Preparing Topup"  
  b02b0_file="b02b0.cnf"
  topup_AP_file=$topup_path"/"$subject_id"_topup_AP"
  topup_AP_iout_file=$topup_path"/"$subject_id"_topup_AP_iout"
  
  echo "-->> Running Topup with:"
  echo "-->> $dwi_file"
  echo "-->> $acqparam_file"
  echo "-->> $b02b0_file"
  echo "-->> $topup_AP_file"
  echo "-->> $topup_AP_iout_file"
  echo "-->> $topup_path"
  topup \
  --imain=$dwi_file \
  --datain=$acqparam_file \
  --config=$b02b0_file \
  --out=$topup_AP_file \
  --iout=$topup_AP_iout_file \
  --fout=$topup_path \
  --verbose
  
  exit
fi

# Process for B0 file
if [ "$b0_file" ]; then

  
  # Checking structure of input data
  echo "-->> DWI file information"
  fslinfo $dwi_file  
  #fslinfo $bval_file   
  #fslinfo $bvec_file 


  nodif_file=$b0norm_path"/"$subject_id"_nodif"
  fslroi $dwi_file $nodif_file 0 1
  
  acqparam_file=$subject_path"/acqparams.txt"
  echo "-->> Creating acqparams file"
  #   The first three elements of each line comprise a vector that specifies the direction of the phase encoding.
  #   The non-zero number in the second column means that is along the y-direction. 
  #   A -1 means that k-space was traversed Anterior-Posterior and a 1 that it was traversed Posterior-Anterior. 
  #   The final column specifies the "total readout time"
  #   if you don't have the total readout time, you can obtain this value fallow this: https://lcni.uoregon.edu/kb-articles/kb-0003
  
  printf "0 -1 0 0.01247\n0 1 0 0.01247" > $acqparam_file
   
  #   Merging DWI data and B0 file
  echo "-->> Merging DWI data and B0 file (OutPut: AP_PA_b0.nii.gz )"   
  fslmerge \
  -t $b0norm_path"/"$subject_id"_AP_PA_b0" \
  $nodif_file".nii.gz" $b0_file
  imain_file=$b0norm_path"/"$subject_id"_AP_PA_b0.nii.gz"
  
 # TopUp process: Correct fo susceptibility distortions using merged B0 images with oposite phase encoding directions
  echo "-->> Preparing Topup"
  
  b02b0_file="b02b0.cnf"
  topup_AP_PA_b0_file=$topup_path"/"$subject_id"_topup_AP_PA_b0"
  topup_AP_PA_b0_iout_file=$topup_path"/"$subject_id"_topup_AP_PA_b0_iout"
  
  echo "-->> Running Topup"
  topup \
  --imain=$imain_file \
  --datain=$acqparam_file \
  --config=$b02b0_file \
  --out=$topup_AP_PA_b0_file \
  --iout=$topup_AP_PA_b0_iout_file \
  --fout=$topup_path \
  --verbose
  
  # EDDY - Correcting for Eddy Currents
  echo "-->> Running EDDY"
  echo "-->> Preparing properties"
  
  hifi_nodif_file=$eddy_path"/"$subject_id"_hifi_nodif"
  fslmaths $topup_AP_PA_b0_iout_file".nii.gz" -Tmean $hifi_nodif_file
  
  
  hifi_nodif_brain_file=$eddy_path"/"$subject_id"_hifi_nodif_brain"
  bet $hifi_nodif_file".nii.gz" $hifi_nodif_brain_file -m -f "0.2"

  # Creating the index.txt file
  echo "-->> Creating the index file"
  
  echo "-->> Obtaining DWI_file Info"
  fslinfo $imain_file
  index_file=$eddy_path"/index.txt"
  
  no_dir=`fslval $imain_file dim4`
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
  dwi_bvec_file=$bvec_file
  dwi_bval_file=$bval_file
  dwi_file_name=$imain_file
  #Output
  eddy_unwarped_images_path=$eddy_dtifit_path
  
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

else
 
  dwi_ap_file=$raw_data_path"/"$subject_id"/fmap/"$subject_id"_dir-AP_acq-dwi_epi.nii.gz"
  dwi_pa_file=$raw_data_path"/"$subject_id"/fmap/"$subject_id"_dir-PA_acq-dwi_epi.nii.gz"
  
  echo "-->> Merging AP and PA file (OutPut: AP_PA_b0.nii.gz )"
  fslmerge \
  -t $subject_output_path"/"$subject_id"_AP_PA_b0" \
  $dwi_ap_file $dwi_pa_file
  
  AP_PA_b0_file=$subject_output_path"/"$subject_id"_AP_PA_b0.nii.gz"
  
   
 
  #   Applying topup
  echo "-->> Applying Topup"
  applay_topup_path=$subject_output_path"/ApplyTopup"
  mkdir -p $applay_topup_path
  
  applytopup \
  --imain=$dwi_ap_file,$dwi_pa_file \
  --topup=$topup_AP_PA_b0_file \
  --datain=$acqparam_file \
  --inindex=1,2 \
  --out=$applay_topup_path"/hifi_nodif_qc"
             
  hifi_nodif_file_qc=$applay_topup_path"/hifi_nodif_qc.nii.gz"
fi

echo "-->> Done"