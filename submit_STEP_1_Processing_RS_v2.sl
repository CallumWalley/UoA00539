#!/bin/bash -e
#=============================================================================#
#title submitter.sh
#description Submission script for Steven Wolfson
#author Callum
#==============================================================================#

#=================MEMORY==================#
# If DOWNSAMPLE_RATE > 15 | 10G is plenty.
# If DOWNSAMPLE_RATE < 15 | APPROX (20-DOWNSAMPLE_RATE)^2
#=========================================#



#====================================PATHS=====================================#

RUN_DIR="/nesi/project/nesi99999/Callum/FractalAutism/UoA00539_o/code"            # Code Location
INPUT_DIR="/nesi/project/nesi99999/Callum/FractalAutism/UoA00539_o/inputs"        # All .RAW files in this directory will be proccessed.
OUTPUT_DIR="/nesi/project/nesi99999/Callum/FractalAutism/UoA00539_o/outputs"      # Outputs will be placed here.

#===================================SETTINGS===================================#

WORKERS=0                # 0 out for max, set to 1 to disable parpool.
DOWNSAMPLE_RATE=50       # See memory
PROFILE="true"           # Enables MATLAB profiling. Also need to uncomment '--profiling' in slurm header. 
MEM="5G"
CPUS="4"
NAME="Test"
TIME="00:15:00"

#==============================================================================#

# Avoid possible future version issuessa
module load MATLAB/2018b

submitJob () {

# Disable JVM if serial
if [ ! -z "${WORKERS}" ] && [ "${WORKERS}" == "1" ]; then
    JVM="-nojvm"
fi

if [ ${PROFILE} == 'true' ]; then
    S_PROFILE="#SBATCH --profile=ALL"
fi



tempfile=.slurm$((tempnam)).sl
cat <<EOF > ${tempfile}
#!/bin/bash -e

#SBATCH --time=${TIME}
#SBATCH --job-name=${NAME}_${FILENAME}
#SBATCH --output=step1RS-%A.output
#SBATCH --cpus-per-task=${CPUS}          
#SBATCH --mem=${MEM}
##SBATCH --hint=nomultithread
#SBATCH --qos debug
${S_PROFILE}

cd $RUN_DIR

matInput="
run_dir='${RUN_DIR}';\
output_dir='${OUTPUT_DIR}';\
input_path='${INPUT_PATH}';\
downsampleRate=${DOWNSAMPLE_RATE};\
setWorkers=${WORKERS};\
profile=${PROFILE};\
STEP_1_Processing_RS_v3;\
exit;\
"

echo "Input to matlab;  \${matInput}"
matlab -nodisplay ${JVM} -nosplash -r "\${matInput}"

#Add script to ouput
cat \${0}  

EOF

#Submit job and pipe job ID to variable.
sbatch ${tempfile}
#rm ${tempfile}
}

for INPUT_PATH in ${INPUT_DIR}/*.RAW; do  
    #echo $INPUT_PATH
    FILENAME=$(basename ${INPUT_PATH})
    printf "Using input file ${FILENAME}\n"   
    
    
    submitJob
        # dir_name="${FILENAME}"
        # #If directory of this name doesn't allready exist.
        # if [ ! -d "${dir_name}" ]; then        
        #     mkdir ${dir_name}
        #     cd ${dir_name}
        #     submitJob
        # else
        #     echo "${dir_name} already exists, skipping..."
        # fi
done