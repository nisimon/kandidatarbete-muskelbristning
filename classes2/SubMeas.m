classdef SubMeas
    %SUBMEAS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SParams
    end
    
    methods
        function SPs = getSParams(obj, SNames)
        % Returns a cell array of S-parameters with names matching SNames
            SPs = cell(size(SNames));
            for i=1:length(SPs)
                SPidx = 0;
                found = 0;
                j = 1;

                while j <= length(obj.SParams) && found == 0
                    if strcmp(getName(obj.SParams{j}),SNames{i})
                        SPidx = j;
                        found = 1;
                    end
                    j = j + 1;
                end

                if found == 0
                    error('S-parameter %s not found',...
                        SNames{i});
                end

                SPs{i} = obj.SParams{SPidx};
            end
        end
        
        function SPs = getAllSParams(obj)
            SPs = obj.SParams;
        end
        
        function numSP = getNumSParams(obj)
            numSP = length(obj.SParams);
        end
        
        function vector = vectorize(obj, SNames)
            % Create list of vectorized S-parameters sorted by name
            % if no names given, use all S-parameters
            if isempty(SNames)
                SNames = cell(size(obj.SParams));
                for i = 1:length(SNames)
                    SNames{i} = getName(obj.SParams{i});
                end
            end
            
            [sortedSNames, ~] = sort(SNames);
            
            sortedSParams = obj.getSParams(sortedSNames);
            
            vector = [];
            
            % TODO: Preallocate vector
            for i = 1:length(sortedSParams)
                vector = [vector; getComplexData(sortedSParams{i})];
            end
        end
    end
    
end

