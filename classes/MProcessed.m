classdef MProcessed < SubMeas
    %MPROCESSED Processed measurement created from repetitions
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MProcessed(mReps, varargin)
            % Get reference measurement if supplied
            if length(varargin) == 1
                mRef = varargin{1};
            else
                mRef = {};
            end
            
            numReps = length(mReps);
            if numReps <= 0
                error('Must supply at least one repetition');
            %elseif numReps == 1
            %    % If 1 repetition, just copy the S-parameters
            %    obj.SParams = getAllSParams(mReps{1});
            else
                % Initialize temporary S-parameter struct
                sParamCells = cell(1,getNumSParams(mReps{1}));
                SPStruct = struct('name',sParamCells,'freq',sParamCells,...
                                    'S',sParamCells, 'reps',sParamCells,...
                                    'excl',sParamCells);
                for i = 1:numReps;
                    % Sum each S-parameter over all repetitions
                    tempSParams = getAllSParams(mReps{i});
                    if length(tempSParams) ~= length(SPStruct)
                        error('Mismatch in number of S-parameters');
                    end
                    for j = 1:length(tempSParams)
                        if i == 1
                            % Copy S-Parameters first iteration
                            SPStruct(j).name = getName(tempSParams{j});
                            SPStruct(j).freq = getFreq(tempSParams{j});
                            SPStruct(j).S = getComplexData(tempSParams{j});
                            SPStruct(j).excl = isExcluded(tempSParams{j});
                            SPStruct(j).reps = 1;
                        else
                            % Sum S-parameters following iterations
                            if ~isExcluded(tempSParams{j})
                                % Do nothing if current S-parameter
                                % is excluded
                                currName = getName(tempSParams{j});
                                currIdx =...
                                    find(strcmp({SPStruct.name},currName));
                                if length(currIdx) ~= 1
                                    error('S-parameter name mismatch');
                                end
                                currIdx = currIdx(1);
                                if SPStruct(currIdx).excl
                                    % If all previous S-parameters were
                                    % excluded overwrite with this one
                                    SPStruct(currIdx).S =...
                                        getComplexData(tempSParams{j});
                                    SPStruct(currIdx).excl = false;
                                else
                                    SPStruct(currIdx).S =...
                                        SPStruct(currIdx).S +...
                                        getComplexData(tempSParams{j});
                                    SPStruct(currIdx).reps = ...
                                        SPStruct(currIdx).reps + 1;
                                end
                            end
                        end
                    end
                end
                
                for i = 1:length(SPStruct)
                    % Calculate average for each S-parameter
                    tempS = SPStruct(i).S;
                    SPStruct(i).S = tempS./SPStruct(i).reps;
                    
                    % Subtract reference measurement if it exists
                    if ~isempty(mRef)
                        refProcMeas = getProcMeas(mRef);
                        try
                            refS = getSParams(refProcMeas,...
                                {SPStruct(i).name});
                            if isExcluded(refS{1})
                                % Exclude S-parameter if reference
                                % S-parameter is excluded
                                SPStruct(i).excl = true;
                            else
                                SPStruct(i).S =...
                                    smooth(abs(SPStruct(i).S) -...
                                    getAmplData(refS{1}),11);
                            end
                        catch E
                            disp(E);
                            % Set S-parameter to excluded if unable to
                            % get reference S-parameter
                            SPStruct(i).excl = true;
                        end 
                    end
                    
                    % Construct S-parameters
                    sParamCells{i} = SParam(SPStruct(i));
                end
                
                obj.SParams = sParamCells;
            end
        end
        
    end
end

