clear; close all; clc; bdclose('all');
% replace this path with yours
% add path
home = '/Users/ldy/git/FalBenchGen_ARCHCOMP25';
addpath(genpath(home));
addpath(genpath('/Users/ldy/git/CPSTutorial/S-TaLiRo'));
% model name
model = 'phi1_m2_vr001_k5_2';
% model parameters
T = 24;
Ts = 1;
% falsification parameters
cp_num = [4;4];
inputRange = [0,1;0,1];
% simulation time & requirements (run " help staliro" for more information)
SP.t0 = 0;
SP.tf = T;
SP.pred(1).str = 'p1';
SP.pred(1).A = 1;
SP.pred(1).b = 20;
SP.phi = '[]_[0,24](p1)';
% set solver parameters
trials = 30;
opt = staliro_options();
opt.optimization_solver = 'SA_Taliro';
opt.falsification = 1;
opt.SampTime = Ts;
opt.interpolationtype = {'pconst'};
opt.runs = trials;
opt.optim_params.n_tests = 1000;
% falsification
[results, history] = staliro(model,[],inputRange,cp_num,SP.phi,SP.pred,SP.tf,opt);