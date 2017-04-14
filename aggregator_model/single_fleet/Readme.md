# Single fleet optimizer

## Model description and assumptions
The aggregator model is implemented assuming that it has centralized control over a fleet of Electric Vehicles. The electric vehicles are dispatched (charged or discharged) depending on the flexibility requirements of the electric grid. From the commercial perspective, the aggregator is assumed to be a price taker and unable to affect energy prices.

In order to model the requirements of the grid a representative price profile for California is used. The price profile is obtained from a system simulation of the WECC for year 2024 under 3 different scenarios. 

- Case0 - State-wide Electric Vehicle Fleet is small and has no effect on the prices. 
- Case1 - State-wide Electric Vehicle Fleet is large and unmanaged i.e., no smart charging. 
- Case2 - State-wide Electric Vehicle Fleet is large and operated with smart charging.

The mathematical model of the aggregator is as follows: 

$$
\min \sum_{i \in I} c^g_{i} \cdot g_{i} + c^w \cdot w,
$$

This problem is concerned with the implementation of the analytical solution to calculate the roots of a second degree polynomial. More specifically, handling large numbers that can overflow the floating point operations and lead to wrong results. In this paricular case, take the solution of the quadratic polynomial $\frac{-b \pm \sqrt{b^2-4ac}}{2a}$, this form of the solution can create imprecisions for large numbers if the term $\sqrt{b^2-4ac}$ is approximated as $|b|$. 

The book explores the following reformulations and requires a discussion on their merits or problems: 

* $\frac{-2c}{b \pm \sqrt{b^2 - 4ac}}$: 
* $\frac{-b}{2a}\left( 1 \pm \sqrt{1 - \frac{4ac}{b^2}} \right)$: 
* $\frac{-2c}{b\left( 1 \pm \sqrt{1 - \frac{4ac}{b^2}} \right)}$: 

This reformulation eliminates problems related to overflow and yet it maintains the precision of the results if the value $b$ provided is larger than the maximum $\texttt{int64}$. The first re-formulation can be used to avoid precision issues when $b^2 >> a4c$, the sign used depends on the sign of $b$. 