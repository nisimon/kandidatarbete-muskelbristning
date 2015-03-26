function dataSet = loadAllData( paths )
%LOADALLDATA Summary of this function goes here
%   Detailed explanation goes here

    % Assume that all data is equal in size, only check first one
    [~, numFiles] = queryData(paths{1});
    n = sqrt(numFiles);
    numMeas = length(paths);
    
    % Initialize data structure
    emptyCells = cell(1, n*n);
    dataSet = struct('S', emptyCells, ...
                    'meas', emptyCells);

    % Loop through all s-parameters
    for i=1:n
        for j=1:n
            SParam = cellstr(strcat('S',num2str(i),'_',num2str(j)));
            % Load one set of data into the structure
            emptyCells = cell(1, numMeas);
            measData = struct('name',emptyCells,'data',emptyCells);
            for k=1:numMeas
                loadedData = loadData(paths{k},i,j);
                name = getName(paths{k});
                measData(k).name = name;
                measData(k).data = loadedData;
            end
            idx = (i-1)*n + j;
            dataSet(idx).S = SParam;
            dataSet(idx).meas = measData;
        end
    end
    
end

