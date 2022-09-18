#!/bin/bash

echo 'Launching Jobs'
echo '---------------------------------------------------------------------------------------------'

print_help(){
    echo -e "Usage: ./$0 [-p <jobname_prefix>] <jobs_file>"
    echo -e "\t\t jobname_prefix: \tValue prepended to jon_name (Default: '')"
    echo
}

jobname_prefix=""
while getopts p:h flag
do
    case "${flag}" in
        p) jobname_prefix="${OPTARG}."
            shift;;
        *)
            print_help;
            exit -1;
        ;;
    esac
    shift;
done

if [[ $# -ne 1 ]]
then
    print_help;
    exit -1;
fi

jobs_file="$1"

echo "jobs_file: $jobs_file"
echo 

jobid=0;
for d in $(cat $jobs_file)
do
    job_major=$(echo $d | sed -e 's/.*\/(.*?)\/(.*)$/\1/')
    job_minor=$(echo $d | sed -e 's/.*\/(.+?)\/(.+)$/\2/')
    job_name="$job_major.$jobid"

    echo "Job: $job_major/$job_minor"
    echo "job_name: $job_name"

    # helm install $job_name chart/fft_boxing/ \
    #     --set jobParam.name="$job_name" \
    #     --set jobParam.dataDir="$d"    \
    #     --set jobParam.description="dir: $d"    


    ((jobid=jobid+1))
done