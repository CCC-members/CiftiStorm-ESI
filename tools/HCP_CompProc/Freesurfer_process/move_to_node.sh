#!/bin/bash 

script_path=$1
freesurfer_ws=$2
node=$3
data_dir=$4
subject_name=$5


echo "Login done in node: "$node
ssh -X $node << EOF
#sshpass -p $password ssh -tt $node << EOF
echo "-->> Input params"
echo "----------------------------------------------------------"
echo "Freesurfer Workspace: "$freesurfer_ws
echo "Data path: "$data_dir
echo "Node: "$node
echo "Id node: "$idnode
module load freesurfer-7.2.0
if test -f "$script_path/freesurfer_process.sh"; then
  cd $script_path
   ./freesurfer_process.sh $freesurfer_ws $data_dir $subject_name	
else
  echo "The file: 'run_process.sh' cannot be found in the current folder"
fi
#exit
>/dev/null
EOF
#exit
