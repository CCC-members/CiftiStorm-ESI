#!/bin/bash 
tittle="------Executing Freesurfer multi process on Linux------"
echo ""
echo $tittle
echo ""
echo "-->> Starting process..."
username=""
password=""
ciftify_ws="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/derivatives/ciftify"
bet_ws="/data3_260T/data/CCLAB_DATASETS/CHBM/CHBM_ARIOSKY/Data_report/DS_BIDS_CHBM/derivatives/FSL_Bet" 

if test -d "$ciftify_ws"; then
  declare -a nodes=("node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03" "node03" "node04" "node04" "node04" "node05" "node05" "node05" "node06" "node06" "node06" "node07" "node07" "node07" "node08" "node08" "node08" "node09" "node09" "node09" "node10" "node10" "node10" "node01" "node01" "node01" "node02" "node02" "node02" "node01" "node01" "node01" "node02" "node02" "node02" "node03" "node03")  
  N=${#nodes[@]}
  echo "Total of instances: "$N
  subjects=($(find $ciftify_ws/* -maxdepth 0 -type d))  
  sub_seg=0
  nsubjects=${#subjects[@]}
  echo "Total of subjects: "$nsubjects
  script_path="`pwd`"
  function_name="Main"
  idnode=0
  if test -f "$script_path/move_to_node.sh"; then
    for node in "${nodes[@]}"; do
      (   
        if [[ $idnode -lt $nsubjects ]]; then
          echo "Moving to node: "$node" in instance :"$idnode
          subject=${subjects[$idnode+$sub_seg]}
          subject_dir=`dirname $subject`
    	  subject_name=`basename $subject`
	  echo $subject_name
	  if test -d "$bet_ws/$subject_name"; then
       	    echo "Subject folder: "$subject_name" already exist"
          else	        
      	    gnome-terminal --geometry=25x2 --tab --title="$node" --command="bash -c '$script_path/move_to_node.sh $script_path $node $ciftify_ws $bet_ws $subject_name'"      	    
          fi
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
