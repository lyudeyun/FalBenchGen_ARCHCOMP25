# FalBenchGen_ARCH-COMP2025

This repository provides five benchmarks we selected from FalBenchGen and the necessary scripts for the falsification category of ARCH-COMP 2025.

## Quick Links
- [Five Benchmarks and Their Specifications](##five-benchmarks-and-their-specifications)
- [Benchmark](./benchmark/)
- [Breach Demo](./scripts/)
- [S-TaLiRo Demo](./scripts/staliro_simulink/)


## Five Benchmarks and Their Specifications

Here are five specifications and thier corresponding benchmarks for falsification.  
The naming convention for these benchmarks is as follows: phi[Specification Index]\_m[Input Number]\_vr[Violation Ratio]\_k[Training Parameter Index]\_[Repeat Index].

| Benchmark | Index | Specification |
| ----- | ----- | ----- |
| phi1_m2_vr001_k5_2 | phi1 | □ <sub>[0,24]</sub> (b < 20) |
| phi2_m1_vr01_k2_2 | phi2 | □ <sub>[0,18]</sub> (b > 90 ∨ ◊ <sub>[0,6]</sub> (b < 50)) |
| phi3_m2_vr001_k3_2 | phi3 | ◊ <sub>[6,12]</sub> (b > 10) -> □ <sub>[18,24]</sub> (b > -10) |
| phi4_m2_vr001_k5_3 | phi4 | □ <sub>[0,19]</sub> (□ <sub>[0,5]</sub> ($b_1$ ≤ 20) ∨ ◊ <sub>[0,5]</sub> ($b_2$ ≥ 40)) |
| phi5_m1_vr01_k5_2 | phi5 | □ <sub>[0,17]</sub> (◊ <sub>[0,2]</sub> (¬(□ <sub>[0,1]</sub> ($b_1$ ≥ 9)) ∨ □ <sub>[1,5]</sub>($b_2$ ≥ 9))) |
 
## Deyun's Software and Hardware Dependencies

- Macbook Pro 2022 with M2 Max Chip
- Matlab 2024b
    - Simulink
    - [Deep Learning Toolbox](https://www.mathworks.com/products/deep-learning.html)
- Breach Version: 1.8.0
- S-TaLiRo

## Falsification Parameter Setup

- Simulation time: 24 (secs)
- Time step size: 1 (sec)
- External input number: 1 or 2
- Input range: [0, 1]
- Number of control points: 4
- Falsification trials: 30
- Falsification budget: 1000

## Repository Structure Tree

```
.
├── README.md
├── benchmark
│   ├── lstm
│   │   ├── phi1_m2_vr001_k5_2.mat
│   │   ├── phi2_m1_vr01_k2_2.mat
│   │   ├── phi3_m2_vr001_k3_2.mat
│   │   ├── phi4_m2_vr001_k5_3.mat
│   │   └── phi5_m1_vr01_k5_2.mat
│   └── simulink
│       ├── phi1_m2_vr001_k5_2.slx
│       ├── phi2_m1_vr01_k2_2.slx
│       ├── phi3_m2_vr001_k3_2.slx
│       ├── phi4_m2_vr001_k5_3.slx
│       └── phi5_m1_vr01_k5_2.slx
├── result
│   ├── breach_phi1_m2_vr001_k5_2.txt
│   ├── breach_phi2_m1_vr01_k2_2.txt
│   ├── breach_phi3_m2_vr001_k3_2.txt
│   ├── breach_phi4_m2_vr001_k5_3.txt
│   └── breach_phi5_m1_vr01_k5_2.txt
├── scripts
│   ├── breach_lstm
│   │   ├── breach_lstm_phi1.m
│   │   ├── breach_lstm_phi2.m
│   │   ├── breach_lstm_phi3.m
│   │   ├── breach_lstm_phi4.m
│   │   ├── breach_lstm_phi5.m
│   │   └── traces_signal_gen.m
│   ├── breach_simulink
│   │   ├── breach_simulink_phi1.m
│   │   └── lstm2Sim.m
│   └── staliro_simulink
│       └── staliro_simulink_phi1.m
└── utils
    ├── CQueue.m
    ├── MCTS.m
    ├── MCTS_Node.m
    ├── Region.m
    ├── myState.m
    ├── my_treelayout.m
    ├── my_treeplot.m
    └── processCPSData.m
```

## Usage

### Breach Installation

- Clone the repository of `breach`
    - Use `git clone git@github.com:Fenking/FalBenchGen.git`
- Install [Breach](https://github.com/decyphir/breach).
    1. `git clone -b 1.8.0 git@github.com:decyphir/breach.git`
    2. Start matlab, set up a C/C++ compiler using the command `mex -setup C++`. (Refer to [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html) for more details.)
    3. Navigate to `breach/` in Matlab commandline, and run `InstallBreach`
- Setting of CMAES Algorithm (Modify the seed of CMA-ES algorithm for falsification)
    1. `vi /breach/Core/Algos/@BreachProblem/BreachProblem.m`;
    2. Replace the line `solver_opt.Seed = 0` with `solver_opt.Seed = round(rem(now, 1)*1000000)` in the `setup_cmaes` function.
- Setting of SA Algorithm (Fix a bug in `Breach 1.8.0`)
    1. `vi /breach/Core/Algos/@BreachProblem/BreachProblem.m`;
    2. Replace all the `saoptimset` to `optimset` in the function `solver_opt = setup_simulannealbnd(this)`.

### S-TaLiRo Installation


### Reproduction of Experimental Results

There are two ways to use our benchmark. Here, we use `Breach` to introduce the steps for performing falsification using our benchmarks.
1. Falsification based on LSTM
  - Navigate to folder `/scripts/breach_lstm`;
  - Open the script `breach_lstm_[Specificaiton Index].m`;
  - eplace the path of our repository and the path of `breach` with yours;
  - Run the script `breach_lstm_[Specificaiton Index].m`
2. Falsification based on the simulink model embedded with an LSTM
  - Breach
     - Navigate to folder `/scripts/breach_simulink`;
     - Open the script `breach_simulink_[Specificaiton Index].m`;
     - Replace the path of our repository and the path of `breach` with yours;
     - Run the script `breach_simulink_[Specificaiton Index].m` (Here we only provide the script for `phi1`)
  - S-TaLiRo
     - Navigate to folder `/scripts/staliro_simulink`;
     - Open the script `staliro_simulink_[Specificaiton Index].m`;
     - Replace the path of our repository and the path of `breach` with yours;
     - Run the script `staliro_simulink_[Specificaiton Index].m` (Here we only provide the script for `phi1`)




