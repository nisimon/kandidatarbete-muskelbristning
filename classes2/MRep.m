classdef MRep
    %MREP Class containing a repetition of a measurement
    %   Consists of an array of SParams
    
    properties
        rName
        SParams
    end
    
    methods
        function obj = MRep(path)
        % Construct an MRep from path to directory containing data files
            if ~isdir(path)
                error('Must specify a directory');
            end
            
            % Get name of repetition
            % Same as name of folder
            pathComponents = strsplit(path,filesep);
            obj.rName = pathComponents{end};
            
            % Get list of paths to M-files in directory
            listing = dir(strcat(path,filesep,'*.m'));
            mFileIdxs = ~[listing.isdir];
            mFileNames = {listing(mFileIdxs).name};
            mFilePaths = strcat(path,filesep,mFileNames);
            
            % Create S-parameters
            obj.SParams = cell(1,length(mFilePaths));
            for i = 1:length(obj.SParams)
                obj.SParams{i} = SParam(mFilePaths{i});
            end
        end
        
        function name = getName(obj)
            name = obj.rName;
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

