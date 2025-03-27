clc; clear; close all;
% replace this path with yours
% add path
home = '/Users/ldy/git/FalBenchGen_ARCHCOMP25/';
addpath(genpath(home));
lstmPath = [home, '/benchmark/lstm/'];
modelPath = [home, '/benchmark/simulink/'];

lstmName = 'phi1_m2_vr001_k5_2';
modelName = 'phi1_m2_vr001_k5_2';
inputNum = 2;
outputNum = 1;

% lstmName = 'phi2_m1_vr01_k2_2';
% modelName = 'phi2_m1_vr01_k2_2';
% inputNum = 1;
% outputNum = 1;

% lstmName = 'phi3_m2_vr001_k3_2';
% modelName = 'phi3_m2_vr001_k3_2';
% inputNum = 2;
% outputNum = 1;

% lstmName = 'phi4_m2_vr001_k5_3';
% modelName = 'phi4_m2_vr001_k5_3';
% inputNum = 2;
% outputNum = 2;

% lstmName = 'phi5_m1_vr01_k5_2';
% modelName = 'phi5_m1_vr01_k5_2';
% inputNum = 1;
% outputNum = 2;

Ts = 1;
new_system(modelName);
open_system(modelName);

if inputNum > 1
    % define the Mux block position
    muxCenterY = 110;   % given center Y-coordinate
    spacing = 40;       % distance between input blocks
    inputX = 100;       % X position for input blocks
    muxX = 160;         % X position for the Mux block

    % add Mux block
    muxBlock = add_block('simulink/Signal Routing/Mux', [modelName '/Mux']);
    set_param(muxBlock, 'Inputs', num2str(inputNum));
    set_param(muxBlock, 'Position', [muxX, muxCenterY - (inputNum-1)*spacing/2, muxX + 5, muxCenterY + (inputNum-1)*spacing/2]);

    % loop to create input blocks and connect them symmetrically
    for i = 1:inputNum
        % compute Y position for each input
        inputY = muxCenterY - (inputNum-1) * spacing / 2 + (i-1) * spacing;

        % add Input block
        inputBlock = add_block('simulink/Sources/In1', [modelName '/Input' num2str(i)], ...
            'Position', [inputX, inputY, inputX + 40, inputY + 20]);

        % connect Input block to Mux
        add_line(modelName, ['Input' num2str(i) '/1'], ['Mux/' num2str(i)]);
    end
else
    % add an single input block
    inputBlock = add_block('simulink/Sources/In1', [modelName '/Input']);
    set_param(inputBlock, 'Position', [100, 100, 140, 120]);
end

% add stateful predict block
predictBlock = add_block('deeplib/Stateful Predict', [modelName '/StatefulPredict']);
set_param(predictBlock, 'Position', [200, 60, 340, 160]);
set_param(predictBlock, 'Network', 'network from mat-file');    % set network to load from MAT-file
set_param(predictBlock, 'NetworkFilePath', fullfile([lstmPath, lstmName, '.mat']));           % set MAT file path
set_param(predictBlock, 'SampleTime', num2str(Ts));             % set sample time

if inputNum > 1
    % connect Mux to StatefulPredict
    add_line(modelName, 'Mux/1', 'StatefulPredict/1');
else
    % connect Input to StatefulPredict
    add_line(modelName, 'Input/1', 'StatefulPredict/1');
end

if outputNum > 1
    % add Demux Block
    demuxBlock = add_block('simulink/Signal Routing/Demux', [modelName '/Demux']);
    set_param(demuxBlock, 'Outputs', num2str(outputNum));
    set_param(demuxBlock, 'Position', [400, 80, 405, 140]);

    % get the position of the Demux block
    demuxPos = get_param([modelName '/Demux'], 'Position');
    demuxX = demuxPos(3);                                           % right-side X coordinate
    demuxY = (demuxPos(2) + demuxPos(4)) / 2;                       % calculate the center Y coordinate

    % calculate the Y position of the Outport blocks
    spacing = 40;                                                   % control the spacing between output blocks
    baseY = demuxY - (outputNum - 1) * spacing / 2;                 % compute the Y coordinate of the first Outport block
    outX = demuxX + 60;                                             % X coordinate for the Outport blocks

    for i = 1:outputNum
        % add an Outport block
        outputBlock = add_block('simulink/Sinks/Out1', [modelName '/Output' num2str(i)], ...
            'Position', [outX, baseY + (i - 1) * spacing, outX + 40, baseY + (i - 1) * spacing + 20]);
        % connect the Demux block to the Outport block
        add_line(modelName, ['Demux/' num2str(i)], ['Output' num2str(i) '/1']);
    end

    % connect blocks
    add_line(modelName, 'StatefulPredict/1', 'Demux/1');
else
    % add output block
    outputBlock = add_block('simulink/Sinks/Out1', [modelName '/Output']);
    set_param(outputBlock, 'Position', [400, 100, 440, 120]);

    % connect blocks
    add_line(modelName, 'StatefulPredict/1', 'Output/1');
end

% save Simulink model
save_system(modelName);
close_system(modelName);
% move Simulink model
movefile([modelName, '.slx'], fullfile([modelPath, modelName, '.slx']));
disp('Model generated successfully.');


