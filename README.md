# FalBenchGen_ARCH-COMP2025

This repository provides five benchmarks we selected and the necessary scripts for the falsification category of ARCH-COMP 2025.

## Five Benchmarks and Their Specifications

Here are five specifications and thier corresponding benchmarks for falsification.  
The naming convention for these benchmarks is as follows: phi[Specification Index]\_m[Input Number]\_vr[Violation Ratio]\_k[Training Parameter Index]\_[Repeat Index].

| Benchmark | Index | Specification |
| ----- | ----- | ----- |
| phi1_m1_vr01_k3_2 | phi1 | □ <sub>[0,24]</sub> (b < 20) |
| phi1_m2_vr001_k5_2 | phi1 | □ <sub>[0,24]</sub> (b < 20) |
| phi2_m1_vr01_k2_2 | phi2 | □ <sub>[0,18]</sub> (b > 90 ∨ ◊ <sub>[0,6]</sub> (b < 50)) |
| phi3_m2_vr001_k3_2 | phi3 | ◊ <sub>[6,12]</sub> (b > 10) -> □ <sub>[18,24]</sub> (b > -10) |
| phi4_m2_vr001_k5_3 | phi4 | □ <sub>[0,20]</sub> (□ <sub>[0,5]</sub> ($b_1$ ≤ 20) ∨ ◊ <sub>[0,5]</sub> ($b_2$ ≥ 40)) |
| phi5_m1_vr01_k5_2 | phi5 | □ <sub>[0,18]</sub> (◊ <sub>[0,2]</sub> (¬(□ <sub>[0,1]</sub> ($b_1$ ≥ 9)) ∨ □ <sub>[1,5]</sub>($b_2$ ≥ 9))) |

## Falsfication Tool We Used

- Breach, including four falsification algorithms:
  - CM-AS
  - SA (Simulated Annealing)
  - MCTS (Monte-Carlo Tree Search)
  - Random
 
## Software and Hardware Dependencies

- Macbook Pro 2022 with M2 Max Chip
- Matlab/Simulink 2024b
- Breach Version: 1.8.0

## Falsification Parameter Setup

- Simulation time: 24 (secs)
- Time step size: 1 (sec)
- External input number: 1 or 2
- Input range: [0, 1]
- Number of control points: 4
- Falsification trials: 30
- Falsification budget: 1000

## Experimental Results

- phi1_m1_vr01_k3_2

| Algo | SR | Time | #sim |
| ----- | ----- | ----- | ----- |
| CMA-ES |  |  |  |
| SA |  |  |  |  
| MCTS |  |  |  |  
| Random |  |  |  |  

- phi1_m2_vr001_k5_2

| Algo | SR | Time | #sim |
| ----- | ----- | ----- | ----- |
| CMA-ES |  |  |  |
| SA |  |  |  |  
| MCTS |  |  |  |  
| Random |  |  |  |  

- phi2_m1_vr01_k2_2

| Algo | SR | Time | #sim |
| ----- | ----- | ----- | ----- |
| CMA-ES |  |  |  |
| SA |  |  |  |  
| MCTS |  |  |  |  
| Random |  |  |  |  

- phi3_m2_vr001_k3_2

| Algo | SR | Time | #sim |
| ----- | ----- | ----- | ----- |
| CMA-ES |  |  |  |
| SA |  |  |  |  
| MCTS |  |  |  |  
| Random |  |  |  |  

- phi4_m2_vr001_k5_3

| Algo | SR | Time | #sim |
| ----- | ----- | ----- | ----- |
| CMA-ES |  |  |  |
| SA |  |  |  |  
| MCTS |  |  |  |  
| Random |  |  |  |  

- phi5_m1_vr01_k5_2

| Algo | SR | Time | #sim |
| ----- | ----- | ----- | ----- |
| CMA-ES |  |  |  |
| SA |  |  |  |  
| MCTS |  |  |  |  
| Random |  |  |  |  

## Repository Structure Tree


## Usage


### Installation


### Reproduction of Experimental Results









