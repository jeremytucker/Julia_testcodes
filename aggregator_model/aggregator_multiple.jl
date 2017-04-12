#Packages
using JuMP
using DataFrames

if is_linux()
    cplex_path = joinpath(dirname(@__FILE__),"julia_cplex")
    push!(LOAD_PATH, cplex_path)
    using CPLEX
end 

if is_apple()
    using Gurobi
end    

# JuMP model 
if is_linux()
    agg = Model(solver=CplexSolver(CPX_PARAM_EPGAP=1e-04))
end 

if is_apple()
    agg = Model(solver=GurobiSolver(Presolve=1, InfUnbdInfo=1))
end  

#data 
time = 24 #[hrs]
data_p = readtable("CA_Weighted_Price_Case0.csv")
data_c = readtable("car_profile_multiple.csv")
ini = 1
prices = convert(Array,data_p[ini:(ini+time-1),end])
car_availability = convert(Array,data_c)
fleet_types = size(car_availability)[2]
fleet_size = ones(fleet_types)*1000

#Parameters
k_SOC = car_availability #[0-1] 
k_power = car_availability #[0-1]
contract_limit = 0.8 #[%]
bat_size = 30 #[kWh], based on the Nissan Leaf 
charger_power = 7.2 #[kW], based on a 30 Amp Charger
eff_in = 0.85 #[%]
eff_out = 0.78 #[%]
P_max_in = repmat(fleet_size',time,1).*(charger_power*k_power[1:time, 1:fleet_types]) #[kW]
P_max_out = repmat(fleet_size',time,1).*(charger_power*k_power[1:time, 1:fleet_types]) #[kW]
SOC_max = bat_size*repmat(fleet_size',time,1).*k_SOC[1:time, 1:fleet_types] #[kWh]
SOC_min = bat_size*(1-contract_limit)*repmat(fleet_size',time,1).*k_SOC[1:time, 1:fleet_types] #[kWh]
SOC_ini = fleet_size.*bat_size #[kWh] 


@variables agg begin
    P_in[1:time, 1:fleet_types] >= 0
    P_out[1:time, 1:fleet_types] >= 0
    SOC_min[t, f] <= SOC[t = 1:time, f = 1:fleet_types] <= SOC_max[t, f]
    control[t = 1:time, f = 1:fleet_types],  Bin
end 

@constraints agg begin
    0 <= sum(sum(prices[t]/1000*(P_out[t,f] - P_in[t,f]) for t in 1:time) for f in 1:fleet_types)
    P_in[t = 1:time, f = 1:fleet_types] .<=  P_max_in[t,f].*control[t, f]
    P_out[t = 1:time, f = 1:fleet_types] .<=  P_max_in[t,f].*(ones(time, fleet_types)-control[1:time, f])
    SOC[1, 1:fleet_types] .== SOC_ini[1:fleet_types] + (eff_in)*P_in[1, 1:fleet_types] - (1/eff_out)*P_out[1, 1:fleet_types]
    SOC[2:time, 1:fleet_types] .== SOC[1:time-1, 1:fleet_types] + (eff_in)*P_in[2:time, 1:fleet_types] - (1/eff_out)*P_out[2:time, 1:fleet_types]
end

@objective(agg, Max, sum(sum(prices[t]/1000*(P_out[t,f] - P_in[t,f]) for t in 1:time) for f in 1:fleet_types));

solve(agg)

writedlm("results_multi/P_out.txt", getvalue(P_out))
writedlm("results_multi/P_in.txt", getvalue(P_in))
writedlm("results_multi/SOC.txt", getvalue(SOC))

