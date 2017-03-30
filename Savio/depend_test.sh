#!/bin/bash
# Job name:
#SBATCH --job-name=matlab_test
#
# Account:
#SBATCH --account=fc_emac
#
# QoS:
#SBATCH --qos=savio_normal
#
# Partition:
#SBATCH --partition=savio
#
# Request one node:
#SBATCH --nodes=1
#
# Specify one task:
#SBATCH --ntasks-per-node=1
#
# Number of processors for single task needed for use case (example):
#SBATCH --cpus-per-task=1
#
# Mail type:
#SBATCH --mail-type=all
#
# Mail user:
#SBATCH --mail-user=fcastro@berkeley.edu
# Wall clock limit:
#SBATCH --time=00:50:30
#
# first job - no dependencies

array_size=$(head -1 n.par)
iteration_size=$(heaad -1 iter.par)

z1=$(sbatch test_matlab.sh | awk '{print $NF}')

for n in {2..$iteration_size}  
	do 

count=`expr $n - 1`
# an array of multiple jobs can depend on a single job

z_count="z$count"
eval "x$count=$(sbatch --array=1-$array_size --dependency=afterok:${!z_count} test_matlab2.sh | awk '{print $NF}')"
sleep 1


#iteration 2, dependent on the array of x1

x_count="x$count"
eval "z$n=$(sbatch --dependency=afterok:${!x_count} test_matlab.sh | awk '{print $NF}')"
sleep 1

done

env
