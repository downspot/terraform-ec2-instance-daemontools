#!/bin/sh 


if (( $# != 1 )); then
    echo "Usage: ${0} <preprod|prod>"
    exit 1
fi


aws s3 sync run-scripts/clicks_trainer s3://example-contextual-bandit/clicks_trainer
aws s3 sync run-scripts/joiner  s3://example-contextual-bandit/joiner
aws s3 sync run-scripts/recs_trainer  s3://example-contextual-bandit/recs_trainer

    
for i in clicks_trainer joiner recs_trainer ; do 
    terraform workspace list | grep example-contextual-bandit-${1}-${i} > /dev/null 

    if (( $? != 0 )); then
        terraform workspace new example-contextual-bandit-${1}-${i}
    fi

    terraform workspace select example-contextual-bandit-${1}-${i}
    sed -i 's/#ln -s \/var\/service\/'${i}' \/service/ln -s \/var\/service\/'${i}' \/service/g' user_data.sh
    terraform apply -auto-approve -var-file=${1}.tfvars
    sed -i 's/ln -s \/var\/service\/'${i}' \/service/#ln -s \/var\/service\/'${i}' \/service/g' user_data.sh

done
