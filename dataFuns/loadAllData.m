function [ nnMultFreq, nnMultTrans, nnMultPhase, measNames ] = loadAllData( paths, n )
%LOADALLDATA Summary of this function goes here
%   Detailed explanation goes here

    % Assume that all data is equal in size, only check first one
    [dataLength, ~] = queryData(paths{1});

    % Initialize data matrices
    nnMultFreq = zeros(n,n,dataLength, length(paths));
    nnMultTrans = zeros(n,n,dataLength, length(paths));
    nnMultPhase = zeros(n,n,dataLength, length(paths));

    % Get names of measurements
    measNames = cell(1,length(paths));
    for i = 1:length(paths)
        measNames(i) = getName(paths{i});
    end

    % Loop through all s-parameters
    for i=1:n
        for j=1:n
            % Load one set of data into each column
            for k=1:length(paths)
                [nnMultTrans(i,j,:,k),nnMultPhase(i,j,:,k),nnMultFreq(i,j,:,k)] = loadData(paths{k},i,j);
            end
        end
    end
end

