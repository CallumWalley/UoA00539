#!/bin/bash -e

#SBATCH --time=00:15:00
#SBATCH --job-name=Test_pp003005.RAW
#SBATCH --output=step1RS-%A.output
#SBATCH --cpus-per-task=4          
#SBATCH --mem=5G
##SBATCH --hint=nomultithread
#SBATCH --qos debug
#SBATCH --profile=ALL

matInput="
addpath(genpath('/nesi/project/nesi99999/Callum/FractalAutism/UoA00539_o/code'));             output_dir='/nesi/project/nesi99999/Callum/FractalAutism/UoA00539_o/outputs';                 input_path='/nesi/project/nesi99999/Callum/FractalAutism/UoA00539_o/inputs/pp003005.RAW';                 downsampleRate=50;          setWorkers=0;                      profile=true;                         STEP_1_Processing_RS_v3;                    exit;                                       "

echo "Input to matlab;  ${matInput}"
matlab -nodisplay  -nosplash -r "${matInput}"

#Add script to ouput
cat ${0}  

