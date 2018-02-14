#!/bin/sh 


if (( $# != 1 )); then
    echo "Usage: ${0} <preprod|prod>"
    exit 1
fi

    
for i in clicks_trainer joiner recs_trainer ; do 
    terraform workspace list | grep example-contextual-bandit-${1}-${i} > /dev/null 

    if (( $? != 0 )); then
        terraform workspace new example-contextual-bandit-${1}-${i}
    fi

    terraform workspace select example-contextual-bandit-${1}-${i}
    terraform destroy -var-file=${1}.tfvars

done
