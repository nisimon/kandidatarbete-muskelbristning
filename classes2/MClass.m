classdef MClass
    %MCLASS Class containing a class of measurements
    %   Detailed explanation goes here
    
    properties
        cName
        measurements
    end
    
    methods
        function obj = MClass(path)
            % Construct a measurement class from path to a directory
            % containing measurements belonging to the class
            if ~isdir(path)
                error('Must specify a directory');
            end
            
            % Get name of class
            % Same as name of folder
            pathComponents = strsplit(path,filesep);
            if isempty(pathComponents{end})
                obj.cName = pathComponents{end - 1};
            else
                obj.cName = pathComponents{end};
            end
            
            % Get list of paths to folders in directory
            listing = dir(path);
            pathIdxs = [listing.isdir];
            pathIdxs(1:2) = [0 0]; % Ignore '.' and '..'
            if isempty(find(pathIdxs, 1));
                error('Folder contains no measurements');
            else
                measPaths = {listing(pathIdxs).name};
                measPaths = strcat(path,filesep,measPaths);
            end
            
            % Create repetitions
            obj.measurements = cell(1,length(measPaths));
            for i = 1:length(obj.measurements)
                obj.measurements{i} = Measurement(measPaths{i});
            end
        end
        
        function name = getName(obj)
            name = obj.cName;
        end
        
        function n = getN(obj)
            % Returns n, there are n*n S-parameters for each measurement
            % Throws error if n is not equal for all measurements
            tempN = getN(obj.measurements{1});
            for i = 2:length(obj.measurements)
                if getN(obj.measurements{i}) ~= tempN
                    error('Mismatch in number of S-parameters');
                end
            end
            
            n = tempN;
        end
        
        function numMeases = getNumMeases(obj)
            numMeases = length(obj.measurements);
        end
        
        function procMeases = getProcMeases(obj)
            procMeases = cell(1,length(obj.measurements));
            for i = 1:length(obj.measurements)
                procMeases{i} = getProcMeas(obj.measurements{i});
            end
        end
        
        function measNames = getMeasNames(obj)
            measNames = cell(1,length(obj.measurements));
            for i = 1:length(obj.measurements)
                measNames{i} = getName(obj.measurements{i});
            end
        end
    end
    
end

