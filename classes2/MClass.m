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
            obj.cName = pathComponents{end};
            
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
    end
    
end

