function traces = processCPSData(folder, prefix, num)
% processCPSData function can preprocess the data in the dataset and return the preprocessed data.
%
% Inputs:
%   folder: dataset storage folder
%   prefix: prefix of the data
%   dim: dimension of the data
% Outputs:
%   traces: the preprocessed data

filePattern = fullfile(folder, [prefix, '*']);
files = dir(filePattern);

% initialize the preprocessed data
traces = {};

% load data one by one
for fi = 1:numel(files)
    filePath = fullfile(files(fi).folder, files(fi).name);
    fileContent = fileread(filePath);

    % convert the file content into a list of lines
    data = str2num(fileContent);

    [curTraceNum, dataLen] = size(data);
    curTraces = cell(curTraceNum, 1);

    for ri = 1:curTraceNum
        curTraces{ri,1} = reshape(data(ri,:), num, dataLen/num);
    end

    traces = [traces; curTraces];
end
end