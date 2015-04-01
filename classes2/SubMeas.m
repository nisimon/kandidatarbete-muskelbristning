classdef SubMeas
    %SUBMEAS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SParams
    end
    
    methods
        function SP = getSParam(obj, SName)
            SPidx = 0;
            found = 0;
            i = 1;
            
            while i <= length(obj.SParams) && found == 0
                if strcmp(getName(obj.SParams{i}),SName)
                    SPidx = i;
                    found = 1;
                end
                i = i + 1;
            end
            
            if found == 0
                error('S-parameter %s not found',...
                    SName);
            end
            
            SP = obj.SParams{SPidx};
        end
        
        function SPs = getAllSParams(obj)
            SPs = obj.SParams;
        end
        
        function numSP = getNumSParams(obj)
            numSP = length(obj.SParams);
        end
        
        function vector = vectorize(obj)
            % Create list of S-parameters sorted by name
            SNames = cell(size(obj.SParams));
            for i = 1:length(SNames)
                SNames{i} = getName(obj.SParams{i});
            end
            
            [~, I] = sort(SNames);
            
            sortedSParams = obj.SParams(I);
            
            vector = [];
            
            % TODO: Preallocate vector
            for i = 1:length(sortedSParams)
                vector = [vector; getComplexData(sortedSParams{i})];
            end
        end
    end
    
end

