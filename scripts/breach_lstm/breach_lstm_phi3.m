clc; clear; close all;
% replace this path with yours
% add path
home = '/Users/ldy/git/FalBenchGen_ARCHCOMP25/';
addpath(genpath(home));
addpath(genpath('/Users/ldy/git/CPSTutorial/breach'));
%% add BreachSignalGen
% phi1_m2_vr001_k5_2
% phi2_m1_vr01_k2_2
% phi3_m2_vr001_k3_2
% phi4_m2_vr001_k5_3
% phi5_m1_vr01_k5_2
lstmName = 'phi3_m2_vr001_k3_2';
inputNum = 2;
outputNum = 1;
% spec = 'alw_[0,24](b[t] < 20)';
% spec = 'alw_[0,18](b[t] > 90 or ev_[0,6](b[t] < 50))';
spec = 'not (ev_[6,12](b[t] > 10)) or alw_[18,24](b[t] > -10)';
% spec = 'alw_[0,20](alw_[0,5](b1[t]<=20) or ev_[0,5](b2[t]>=40))';
% spec = 'alw_[0,18](ev_[0,2](not(alw_[0,1](b1[t] >= 9)) or alw_[1,5](b2[t]>= 9)))';
phi = STL_Formula('phi',spec);
T = 24.0;
Ts = 1;
inSpan = 6;
ctrPointNum = T/inSpan;
inputRange = [[0.0, 1.0];[0.0,1.0]];
trials = 30; % falsification trials
InitBreach;

name = fullfile([home, '/benchmark/lstm/', lstmName, '.mat']);

disp([newline 'breach starts configuring ' lstmName]);
net = load(name);
sg = traces_signal_gen(inputNum,outputNum,net,T);
Br = BreachSignalGen(sg);
Br.SetTime(0:Ts:T);

% assign values to the piecewise control points
for i = 1:size(inputRange,1)
    curInputRange = inputRange(i,:);
    params = {};
    ranges = [];
    for j = 1:ctrPointNum
        paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
        params{1,j} = paramName;
        ranges = [ranges; curInputRange(1) curInputRange(2)];
    end
    % can be reused
    Br.SetParamRanges(params, ranges);
end
 
resName = fullfile(home, ['/result/breach_', lstmName]);

resDir = fileparts(resName);
if ~exist(resDir, 'dir')
    mkdir(resDir);
end
fid = fopen([resName, '.txt'], 'w');
%% solve problem via cmaes
falsified = [];
time = [];
obj_best = [];
num_sim = [];

disp([newline 'cmaes breach start.']);
curTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(curTime)]);

for n = 1:trials
    falsif_pb = FalsificationProblem(Br,phi);
    % falsification budget
    falsif_pb.max_time = 600;
    falsif_pb.max_obj_eval = 1000;  % 1000
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

successful_runs = find(obj_best<0);
SR = numel(successful_runs);
avgtime = sum(time(successful_runs))/numel(successful_runs);
avgsim = sum(num_sim(successful_runs))/numel(successful_runs);

fprintf(fid, 'breach by cmaes:\n');
fprintf(fid, 'SR = %.2f\n', SR);
fprintf(fid, 'avgtime = %.2f\n', avgtime);
fprintf(fid, '#sim = %.2f\n\n', avgsim);

fprintf(fid, 'num_sim = %d\n', num_sim);
fprintf(fid, 'time = %.8f\n', time);
fprintf(fid, 'obj_best = %.8f\n', obj_best);

%% solve problem via simulannealbnd
falsified = [];
time = [];
obj_best = [];
num_sim = [];

disp([newline 'simulannealbnd breach start.']);
curTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(curTime)]);

for n = 1:trials
    falsif_pb = FalsificationProblem(Br,phi);
    % falsification budget
    falsif_pb.max_time = 600;
    falsif_pb.max_obj_eval = 1000;
    % specific falsification algorithm
    falsif_pb.setup_solver('simulannealbnd');
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

successful_runs = find(obj_best<0);
SR = numel(successful_runs);
avgtime = sum(time(successful_runs))/numel(successful_runs);
avgsim = sum(num_sim(successful_runs))/numel(successful_runs);

fprintf(fid, '\n\nbreach by simulannealbnd:\n');
fprintf(fid, 'SR = %.2f\n', SR);
fprintf(fid, 'avgtime = %.2f\n', avgtime);
fprintf(fid, '#sim = %.2f\n\n', avgsim);

fprintf(fid, 'num_sim = %d\n', num_sim);
fprintf(fid, 'time = %.8f\n', time);
fprintf(fid, 'obj_best = %.8f\n', obj_best);

%% solve problem MCTS
falsified = [];
time = [];
obj_best = [];
num_sim = [];

disp([newline 'MCTS start.']);
curTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(curTime)]);

N_max = 1000;         % total MCTS
T_playout = 40;
scalar = 0.2;
if inputNum == 1
    partitions = 3;
else
    partitions = [2 2];
end

hillClimbAlgo = 'cmaes';

for n = 1:trials
    start_mcts = tic;
    m = MCTS(sg, N_max, scalar, phi, T, ctrPointNum, hillClimbAlgo, T_playout, inputNum, inputRange, partitions);
    time_mcts = toc(start_mcts);

    if min(m.obj_log) < 0
        falsified = [falsified;1];
    else
        falsified = [falsified;0];
    end
    num_sim = [num_sim; numel(m.obj_log)];
    time = [time; time_mcts];
    obj_best = [obj_best; min(m.obj_log)];
end

successful_runs = find(obj_best<0);
SR = numel(successful_runs);
avgtime = sum(time(successful_runs))/numel(successful_runs);
avgsim = sum(num_sim(successful_runs))/numel(successful_runs);

fprintf(fid, '\n\nbreach by MCTS:\n');
fprintf(fid, 'SR = %.2f\n', SR);
fprintf(fid, 'avgtime = %.2f\n', avgtime);
fprintf(fid, '#sim = %.2f\n\n', avgsim);

fprintf(fid, 'num_sim = %d\n', num_sim);
fprintf(fid, 'time = %.8f\n', time);
fprintf(fid, 'obj_best = %.8f\n', obj_best);

%% solve problem via random

num = 1000;
rob_list = [];
falsified = [];
time = [];
obj_best = [];
num_sim = [];

disp([newline 'random breach start.']);
curTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(curTime)]);

for n = 1:trials
    time_random = tic;
    for k = 1:num
        rob_list = [rob_list;k];
        for i = 1:size(inputRange,1)
            curInputRange = inputRange(i,:);
            params = {};
            rands = [];
            for j = 1:ctrPointNum
                paramName = strcat('u', num2str(i-1),'_',num2str(j-1));
                params{1,j} = paramName;
                rands = [rands, curInputRange(1)+(curInputRange(2)-curInputRange(1))*rand()];
            end
            Br.SetParam(params, rands);
        end
        Br.Sim(0:Ts:T);
        rob = Br.CheckSpec(phi);
        rob_list = [rob_list;rob];
        if rob < 0
            break;
        end
    end
    end_time = toc(time_random);
    num_sim = [num_sim;k];
    time = [time;end_time];
    obj_best = [obj_best;rob];
end

successful_runs = find(obj_best<0);
SR = numel(successful_runs);
avgtime = sum(time(successful_runs))/numel(successful_runs);
avgsim = sum(num_sim(successful_runs))/numel(successful_runs);

fprintf(fid, '\n\nbreach by random:\n');
fprintf(fid, 'SR = %.2f\n', SR);
fprintf(fid, 'avgtime = %.2f\n', avgtime);
fprintf(fid, '#sim = %.2f\n\n', avgsim);

fprintf(fid, 'num_sim = %d\n', num_sim);
fprintf(fid, 'time = %.8f\n', time);
fprintf(fid, 'obj_best = %.8f\n', obj_best);
fprintf(fid, '\n');
fprintf(fid, 'rb = %.8f\n', rob_list);

disp([newline 'breach end.']);
curTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
disp(['Time Now: ' datestr(curTime)]);

%% others
fclose(fid);

