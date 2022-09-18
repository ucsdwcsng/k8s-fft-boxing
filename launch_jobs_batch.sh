#!/bin/bash

echo 'Launching Jobs'
echo '---------------------------------------------------------------------------------------------'

print_help(){
    echo -e "Usage: ./$0 [-p <jobname_prefix>] [-d] <jobs_file>"
    echo -e "\t\t -p \t jobname_prefix: \tValue prepended to jon_name (Default: '')"
    echo -e "\t\t -d \t dryrun: \tRun Helm in dryrun mode"
    echo
}

jobname_prefix=""
dryrun=""
while getopts p:hd flag
do
    case "${flag}" in
        p) jobname_prefix="${OPTARG}."
            shift;;
        d) dryrun="--dry-run";;
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

    helm install $job_name chart/fft_boxing/ $dryrun \
        --set jobParam.name="$job_name" \
        --set jobParam.dataDir="$d"    \
        --set jobParam.description="dir: $d"   


    ((jobid=jobid+1))
done