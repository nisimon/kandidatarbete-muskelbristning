classdef RefMeas < SuperMeas
    %REFMEAS Class containing a reference measurement
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = RefMeas(path)
            % Call SuperMeas constructor
            obj = obj@SuperMeas(path);
            
            % Create processed measurement
            obj.mProcessed = MProcessed(obj.mReps);
        end
    end
    
end

