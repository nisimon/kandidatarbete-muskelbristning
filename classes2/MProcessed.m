classdef MProcessed
    %MPROCESSED Processed measurement created from repetitions
    %   Detailed explanation goes here
    
    properties
        SParams
    end
    
    methods
        function obj = MProcessed(mReps)
            numReps = length(mReps);
            if numReps <= 0
                error('Must supply at least one repetition');
            elseif numReps == 1
                % If 1 repetition, just copy the S-parameters
                obj.SParams = getSParams(mReps{1});
            else
                sParamCells = cell(1,getNumSParams(mReps{1}));
                SPStruct = struct('name',sParamCells,'freq',sParamCells,...
                                    'S',sParamCells);
                for i = 1:numReps;
                    % Sum each S-parameter over all repetitions
                    tempSParams = getAllSParams(mReps{i});
                    for j = 1:length(tempSParams)
                        if i == 1
                            % Copy S-Parameters first iteration
                            SPStruct(j).name = getName(tempSParams{j});
                            SPStruct(j).freq = getFreq(tempSParams{j});
                            SPStruct(j).S = getComplexData(tempSParams{j});
                        else
                            % Sum S-parameters following iterations
                            if length(tempSParams) ~= length(SPStruct)
                                error('Mismatch in number of S-parameters');
                            end
                            currName = getName(tempSParams{j});
                            currIdx =...
                                find(strcmp({SPStruct.name},currName));
                            if length(currIdx) ~= 1
                                error('S-parameter name mismatch');
                            end
                            currIdx = currIdx(1);
                            SPStruct(currIdx).S =...
                                SPStruct(currIdx).S +...
                                getComplexData(tempSParams{j});
                        end
                    end
                end
                
                for i = 1:length(SPStruct)
                    % Calculate average for each S-parameter
                    tempS = SPStruct(i).S;
                    SPStruct(i).S = tempS./numReps;
                    % Construct S-parameters
                    sParamCells{i} = SParam(SPStruct(i));
                end
                
                obj.SParams = sParamCells;
            end
        end
        
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
                error('S-parameter %s not found in repetition %s',...
                    SName, obj.rName);
            end
            
            SP = obj.SParams{SPidx};
        end
        
        function SPs = getAllSParams(obj)
            SPs = obj.SParams;
        end
        
        function numSP = getNumSParams(obj)
            numSP = length(obj.SParams);
        end
    end
    
end

