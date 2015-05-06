classdef SuperMeas < handle
    %SUPERMEAS Superclass for measurements
    %   Detailed explanation goes here
    
    properties
        mReps
        mProcessed
    end
    
    methods
        function obj = SuperMeas(path)
            % Construct a measurement from path to a directory
            % containing repetitions of the measurement
            if ~isdir(path)
                error('Must specify a directory');
            end
            
            % Get list of paths to folders in directory
            listing = dir(path);
            pathIdxs = [listing.isdir];
            pathIdxs(1:2) = [0 0]; % Ignore '.' and '..'
            if isempty(find(pathIdxs, 1));
                % If there are no subfolders, assume just one repetition
                % directly in measurement folder
                repPaths = {path};
            else
                repPaths = {listing(pathIdxs).name};
                repPaths = strcat(path,filesep,repPaths);
            end
            
            % Create repetitions
            obj.mReps = cell(1,length(repPaths));
            for i = 1:length(obj.mReps)
                obj.mReps{i} = MRep(repPaths{i});
            end
            
        end
        
        function repNames = getRepNames(obj)
            repNames = cell(1,length(obj.mReps));
            for i = 1:length(obj.mReps)
                repNames{i} = getName(obj.mReps{i});
            end
        end
        
        function allMeas = getAllMeas(obj)
            allMeas = cell(1, length(obj.mReps) + 1);
            for i = 1:length(obj.mReps)
                allMeas{i} = obj.mReps{i};
            end
            allMeas{end} = obj.mProcessed;
        end
        
        function procMeas = getProcMeas(obj)
            procMeas = obj.mProcessed;
        end
    end
    
end