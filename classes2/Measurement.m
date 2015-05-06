classdef Measurement < SuperMeas
    %MEASUREMENT Class containing a measurement
    %   Contains raw repetitions of measurement and a final processed
    %   measurement.
    
    properties
        mName
        mRef
    end
    
    methods
        function obj = Measurement(path)
            % Construct a measurement from path to a directory
            % containing repetitions of the measurement
            
            % Call SuperMeas constructor
            obj = obj@SuperMeas(path);
            
            % Get name of measurement
            % Same as name of folder
            pathComponents = strsplit(path,filesep);
            if isempty(pathComponents{end})
                obj.mName = pathComponents{end - 1};
            else
                obj.mName = pathComponents{end};
            end
            
            % Create reference measurement if file 'ref.txt' exists
            % in measurement directory containing path to reference
            % measurement
            if exist(strcat(path, filesep, 'ref.txt'), 'file') == 2
                refPath = fileread(strcat(path, filesep, 'ref.txt'));
                obj.mRef = RefMeas(refPath);
            else
                obj.mRef = {};
            end
            
            obj.mProcessed = MProcessed(obj.mReps, obj.mRef);
        end
        
        function refMeas = getRefMeas(obj)
            refMeas = obj.refMeas;
        end
        
        function mName = getName(obj)
            mName = obj.mName;
        end
        
    end
    
end

