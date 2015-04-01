classdef MProcessed < SubMeas
    %MPROCESSED Processed measurement created from repetitions
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MProcessed(mReps)
            numReps = length(mReps);
            if numReps <= 0
                error('Must supply at least one repetition');
            elseif numReps == 1
                % If 1 repetition, just copy the S-parameters
                obj.SParams = getAllSParams(mReps{1});
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
    end
end

