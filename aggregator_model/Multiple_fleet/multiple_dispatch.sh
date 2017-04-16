#!/bin/bash
# Job name:
#SBATCH --job-name=aggregator
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
#
# Wall clock limit:
#SBATCH --time=05:00:00
#



for file in Price_profiles/*.csv; 
	do 
	echo "$file"
	sbatch aggregator_solve.sh "$file"
done
