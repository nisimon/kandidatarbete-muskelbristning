classdef DataSet
    %DATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        dataStruct
    end
    
    methods
        function obj = DataSet( mpc )
        %LOADALLDATA Loads all data in directories in paths
        %mpc should be a MeasurePathContainer
            paths = getMeasPaths(mpc);
            
            % Assume that all data is equal in size, only check first one
            [~, numFiles] = queryData(paths{1});
            n = sqrt(numFiles);
            numMeas = length(paths);

            % Initialize data structure
            emptyCells = cell(1, n*n);
            obj.dataStruct = struct('S', emptyCells, ...
                            'meas', emptyCells);

            % Loop through all s-parameters
            for i=1:n
                for j=1:n
                    SParam = cellstr(strcat('S',num2str(i),'_',num2str(j)));
                    % Load one set of data into the structure
                    measData = cell(1,numMeas);
                    for k=1:numMeas
                        measData{k} = Data(getPath(paths{k}),i,j);
                    end
                    idx = (i-1)*n + j;
                    obj.dataStruct(idx).S = SParam;
                    obj.dataStruct(idx).meas = measData;
                end
            end
        end
        
        function meas = getMeas(obj, SParam)
            % Find index of S-parameter in data set
            % Assume one instance of each S-parameter
            sIdx = find(strcmp([obj.dataStruct.S],SParam));
            sIdx = sIdx(1);
            
            meas = obj.dataStruct(sIdx).meas;
        end
        
        function n = getN(obj)
            n = sqrt(length(obj.dataStruct));
        end
    end
end