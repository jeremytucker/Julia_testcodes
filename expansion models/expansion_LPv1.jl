#Packages
using JuMP
using DataFrames

# This line allow running in the cluster or test locally
if is_linux()
    cplex_path = joinpath(dirname(@__FILE__),"julia_cplex")
    push!(LOAD_PATH, cplex_path)
    using CPLEX
end 

if is_apple()
    using Gurobi
end    

# JuMP model definition
# This line allow running in the cluster or test locally
if is_linux()
    expansion = Model(solver=CplexSolver(CPX_PARAM_EPGAP=1e-04))
end 

if is_apple()
    expansion = Model(solver=GurobiSolver(Presolve=1, InfUnbdInfo=1))
end  

#Model Parameters
time = 2 
locations = 2


 # Model description 

 @variables expansion begin 
    P_installed[t=1:time,l=1:locations] >= 0
    P_dispatch[t=1:time,l=1:locations] >= 0
    flow_min(l,l) <= flow[l = 1:locations, l = 1:locations] <= flow_max(l,l)
    control[t=1:time], Bin
end 

 