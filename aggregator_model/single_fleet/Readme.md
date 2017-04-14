# Single fleet optimizer

## Model description and assumptions
The aggregator model is implemented assuming that it has centralized control over a fleet of Electric Vehicles. The electric vehicles are dispatched (charged or discharged) depending on the flexibility requirements of the electric grid. From the commercial perspective, the aggregator is assumed to be a price taker and unable to affect energy prices.

In order to model the requirements of the grid a representative price profile for California is used. The price profile is obtained from a system simulation of the WECC for year 2024 under 3 different scenarios. 

- Case0 - State-wide Electric Vehicle Fleet is small and has no effect on the prices. 
- Case1 - State-wide Electric Vehicle Fleet is large and unmanaged i.e., no smart charging. 
- Case2 - State-wide Electric Vehicle Fleet is large and operated with smart charging.

The mathematical model of the aggregator is as follows: 

$$
\begin{align}
& \max_{P_{t,f}^{out},P_{t,f}^{in}} \sum_{t} \sum_{f}\!\! \left[ \lambda_{elec}(P_{t,f}^{out} - P_{t,f}^{in})\right]
\end{align}
$$
$$
\begin{align}
&P_{s,t}^{in}\le P^{max}_{s} &\quad \forall t, \: s\\ 
&P_{s,t}^{out}\le P^{max}_{s} &\quad \forall t, \: s\\
& SOC^{min}_{s} \le SOC_{s,t} \le SOC^{max}_{s} &\quad \forall t, \: s\\
&SOC_{s,t+1} = SOC_{s,t}+\left(P_{s,t}^{in} \eta^{in}_{s}- \dfrac{P_{s,t}^{out}}{\eta^{out}_{s}}  \right)  \Delta t &\quad \forall t, \: s\\ 
\end{align}
$$

