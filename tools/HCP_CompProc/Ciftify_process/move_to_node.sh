#!/bin/bash 

script_path=$1
node=$2
freesurfer_ws=$3
ciftify_ws=$4
subject_name=$5


echo "Login done in node: "$node
ssh -X $node << EOF
#sshpass -p $password ssh -tt $node << EOF
echo "-->> Input params"
echo "----------------------------------------------------------"
echo "Freesurfer Workspace: "$freesurfer_ws
echo "Ciftify Workspace: "$ciftify_ws
echo "Node: "$node
module load fsl6.0.5
module load freesurfer-7.2.0
if test -f "$script_path/ciftify_process.sh"; then
  cd $script_path
   ./ciftify_process.sh $freesurfer_ws $ciftify_ws $subject_name	
else
  echo "The file: 'ciftify_process.sh' cannot be found in the current folder"
fi
sleep 10
#exit
>/dev/null
EOF
#exit
