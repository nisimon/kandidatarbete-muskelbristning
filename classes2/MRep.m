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
        
        function SP = getSParams(obj)
            SP = obj.SParams;
        end
        
        function numSP = getNumSParams(obj)
            numSP = length(obj.getSParams);
        end
    end
    
end

