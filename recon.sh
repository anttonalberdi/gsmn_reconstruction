#!/bin/bash
#SBATCH --job-name=Recon_HF    # Job name
#SBATCH --ntasks=8                    # Run on a single CPU
#SBATCH --cpus-per-task=8            # Number of CPU cores per task
#SBATCH --mail-user=antton.alberdi@sund.ku.dk
#SBATCH --mem=24gb                   # Job memory request
#SBATCH --time=48:00:00               # Time limit hrs:min:sec

#Note dat file are also created here:
#/maps/projects/mjolnir1/apps/pathway-tools-27.0/ptools-local/pgdbs/user/

module load pathway-tools/27.0 blast/2.13.0 metage2metabo/1.5.3
mkdir /projects/mjolnir1/people/jpl786/campylo_gsmn/recon
m2m recon -g /projects/mjolnir1/people/jpl786/campylo_gsmn/genomes/ -o projects/mjolnir1/people/jpl786/campylo_gsmn/recon -c 8
