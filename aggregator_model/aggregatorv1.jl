#Packages
using JuMP
using DataFrames
using CSV
cplex_path = joinpath(dirname(@__FILE__),"julia_cplex")
push!(LOAD_PATH, cplex_path)
using CPLEX

#data 
time = 8700 #[hrs]
data_p = readtable("CA_Weighted_Price_Case0.csv");
data_c = readtable("car_profile.csv");
ini = 1;
prices = convert(Array,data_p[ini:(ini+time-1),end]);
car = convert(Array,data_c);

# JuMP model 
agg = Model(solver=CplexSolver())
#Parameters
availability = car #[0-1]
contract_limit = 0.8 #[%]
fleet = 1000000 #[units]
bat_size = 30 #[kWh], based on the Nissan Leaf 
charger_power = 7.2 #[kW], based on a 30 Amp Charger
eff_in = 0.85 #[%]
eff_out = 0.78 #[%]
k_power = availability #[0-1]
P_max_in = fleet*charger_power #[kW]
P_max_out = fleet*charger_power #[kW]
SOC_max = fleet*bat_size #[kWh]
SOC_min = fleet*bat_size*(1-contract_limit) #[kWh]
SOC_ini = SOC_max #[kWh] 
k_SOC = availability #[0-1] 

@variables agg begin 
    P_in[t=1:time] >= 0
    P_out[t=1:time] >= 0
    SOC_min*k_SOC[t] <= SOC[t = 1:time] <= SOC_max*k_SOC[t]
    control[t=1:time], Bin
end 

@constraints agg begin
    P_in[1:time] .<=  P_max_in*k_power[1:time].*control[1:time]
    P_out[1:time] .<=  P_max_out*k_power[1:time].*(1-control[1:time])
    SOC[1] == SOC_ini + (eff_in)*P_in[1] - (1/eff_out)*P_out[1]
    SOC[2:time] .== SOC[1:time-1] + (eff_in)*P_in[2:time] - (1/eff_out)*P_out[2:time]
end

@objective(agg, Max, sum(prices[t]/1000*(P_out[t] - P_in[t]) for t in 1:time));

solve(agg)

writedlm("results/P_out.txt", getvalue(P_out))
writedlm("results/P_in.txt", getvalue(P_in))
writedlm("results/SOC.txt", getvalue(SOC))

