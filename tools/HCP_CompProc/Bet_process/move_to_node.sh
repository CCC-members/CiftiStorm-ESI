#!/bin/bash 

script_path=$1
node=$2
ciftify_ws=$3
bet_ws=$4
subject_name=$5


echo "Login done in node: "$node
ssh -X $node << EOF
#sshpass -p $password ssh -tt $node << EOF
echo "-->> Input params"
echo "----------------------------------------------------------"
echo "Ciftify Workspace: "$ciftify_ws
echo "FSL Bet Workspace: "$bet_ws
echo "Node: "$node
echo "Id node: "$idnode
module load fsl6.0.5
if test -f "$script_path/bet_process.sh"; then
  cd $script_path
   ./bet_process.sh $ciftify_ws $bet_ws $subject_name	
else
  echo "The file: 'bet_process.sh' cannot be found in the current folder"
fi
#exit
sleep 10
>/dev/null
EOF
#exit
