echo "->> Starting Ciftify for fmri process..."

anat_path="/home/ariosky/Raw_Data"
echo ""
ciftify_work_dir=""
echo "->> Ciftify OutPut Path: "$ciftify_path



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
