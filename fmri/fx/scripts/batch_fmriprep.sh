#!/bin/bash
#
# This batch file calls on your subject list (which contains both ID and wave number: SID000,wave1). 
# And runs the job_fmriprep.sh file for each subject. 
# It saves the ouput and error files in specified directories.
#
# Set your directories

container=containers/fmriprep-latest-2018-09-05.simg
group_dir=/projects/giuliani_lab/shared/ #set path to directory within which study folder lives
study="PCSR" 
study_dir="${group_dir}""${study}"

# Set subject list
SUBJLIST=`cat subject_list_fmriprep.txt`

# Loop through subjects and run job_mriqc
for SUBJ in $SUBJLIST; do

SUBID=`echo $SUBJ|awk '{print $1}' FS=","`
SESSID=`echo $SUBJ|awk '{print $2}' FS=","`

sbatch --export ALL,subid=${SUBID},sessid=${SESSID},group_dir=${group_dir},study_dir=${study_dir},study=${study},container=${container} --job-name fmriprep --partition=long -n16 --mem=75G --time=20:00:00 -o "${group_dir}"/"${study}"/PCSR_scripts/fMRI/ppc/output/"${SUBID}"_"${SESSID}"_fmriprep_output.txt -e "${group_dir}"/"${study}"/PCSR_scripts/fMRI/ppc/output/"${SUBID}"_"${SESSID}"_fmriprep_error.txt job_fmriprep.sh	
done
