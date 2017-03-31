# Aggregator model 

The contents of this folder are two-fold: 

- Test a simple model of an Electric Vehicle aggregator that dispatches a fleet according to prices. 
- Develop a self contained implementation of Julia's ```CPLEX.jl``` module that can run in [UC Berkeley's Savio cluster](http://research-it.berkeley.edu/services/high-performance-computing/user-guide)

This is work in progress and the current version of the implementation works as follows: 

- CPLEX binary files are locally stored in a folder at the server, this folder is ignored in the repository. 

- The folder ```julia_cplex``` contains the modified version of the [CPLEX module](https://github.com/JuliaOpt/CPLEX.jl). The modifications are minor and intended to redirect the module to the CPLEX libraries stored locally instead of searching for the paths in operating system. 

- The file ```add_solver.jl``` is intended to create the file ```deps.jl``` that directs CPLEX module to the shared libraries stored in CPLEX's *bin* folder.

- In order to use the local version of the module files, I used these two lines to tell the aggregator file ```aggregatorv1.jl``` to look for the module locally 
~~~ Julia
cplex_path = joinpath(dirname(@__FILE__),"julia_cplex")
push!(LOAD_PATH, cplex_path)
~~~

- The problem is dispatched into the cluster using the shell file ```opt_dipatch.sh```

**So far this implementation works** 
