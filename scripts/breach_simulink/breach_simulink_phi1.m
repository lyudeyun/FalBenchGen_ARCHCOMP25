clear;
close all;
clc;
% replace this path with yours
home = '/Users/ldy/git/FalBenchGen_ARCHCOMP25/';
addpath(genpath(home));
addpath(genpath('/Users/ldy/git/CPSTutorial/breach'));
InitBreach;
% model name 
mdl = 'phi1_m2_vr001_k5_2';
%% falsification
Br = BreachSimulinkSystem(mdl);
Br.Sys.tspan =0:1:23;
% set the type of input signals
input_gen.type = 'UniStep';
% control point number
input_gen.cp = 4;
Br.SetInputGen(input_gen);
% set the range of each input signal 
for cpi = 0:input_gen.cp-1
	in_sig = strcat('Input1_u',num2str(cpi));
	Br.SetParamRanges({in_sig},[0.0 1.0]);
    in_sig = strcat('Input2_u',num2str(cpi));
	Br.SetParamRanges({in_sig},[0.0 1.0]);
end

% practitioner can define specific specs here
%%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X
% confirm the names of input and output first!!!!!!!
spec = 'alw_[0,20](Output[t] < 20)';
%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%X%
phi = STL_Formula('phi',spec);
% falsification instance number
trials = 30;
falsified = [];
time = [];
obj_best = [];
num_sim = [];
% perform falsification
for n = 1:trials
	falsif_pb = FalsificationProblem(Br,phi);
    % falsification budget
    % falsif_pb.max_time = 600;
    falsif_pb.max_obj_eval = 1000;
    % specific falsification algorithm
	falsif_pb.setup_solver('cmaes');
	falsif_pb.solve();
	if falsif_pb.obj_best < 0
		falsified = [falsified;1];
	else
		falsified = [falsified;0];
	end
	num_sim = [num_sim;falsif_pb.nb_obj_eval];
	time = [time;falsif_pb.time_spent];
	obj_best = [obj_best;falsif_pb.obj_best];
end

