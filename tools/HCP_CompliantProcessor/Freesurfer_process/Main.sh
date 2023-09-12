#!/bin/bash 
tittle="------Executing Freesurfer multi process on Linux------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
username=""
password=""
freesurfer_ws="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/derivatives/freesurfer"
data_path="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM" 

if test -d "$freesurfer_ws"; then
  declare -a nodes=("gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "gpu01" "gpu01" "gpu01" "gpu02" "gpu02" "gpu02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03")
  subjects=($(find $data_path/* -maxdepth 0 -type d))  
  sub_seg=0
  N=${#nodes[@]}
  echo "Total of instances: "$N  
  script_path="`pwd`"
  function_name="Main"
  idnode=0
  if test -f "$script_path/move_to_node.sh"; then
    for node in "${nodes[@]}"; do
      (   
        echo "Moving to node: "$node" in instance :"$idnode
        subject=${subjects[$idnode+$sub_seg]}
        subject_dir=`dirname $subject`
    	subject_name=`basename $subject`
	echo $subject_name
	if test -d "$freesurfer_ws/$subject_name"; then
       	  echo "Subject folder: "$subject_name" already exist"
        else
          gnome-terminal --geometry=25x2 --tab --title="$node" --command="bash -c '$script_path/move_to_node.sh $script_path $freesurfer_ws $node $data_path $subject_name'" 
        fi      
      ) &
      ((idnode=idnode+1))
      echo ""
     # allow to execute up to $N jobs in parallel
      if [[ $(jobs -r -p | wc -l) -ge $N ]]; then
          # now there are $N jobs already running, so wait here for any job
          # to be finished so there is a place to start next one.
          wait
      fi
    done
  else
    echo "The file: 'move_to_node.sh' cannot be found in the current folder"
  fi
  
  # no more jobs to be started but wait for pending jobs
  # (all need to be finished)
  wait
else
  echo "The address: freesurfer_ws='$function_workspace' is not a directory"
fi

echo "Process finished!!!"
