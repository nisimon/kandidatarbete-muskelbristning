classdef MRep < SubMeas
    %MREP Class containing a repetition of a measurement
    %   Consists of an array of SParams
    
    properties
        rName
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
            
            % Add exclusions if exclusion file 'excl.txt' exists in path
            % 'excl.txt' should contain a regexp to match against the
            % names of the S-parameters
            if exist(strcat(path, filesep, 'excl.txt'), 'file') == 2
                re = fileread(strcat(path, filesep, 'excl.txt'));
                for i = 1:length(obj.SParams)
                    if ~isempty(regexp(obj.SParams{i}.getName,re,'ONCE'))
                        obj.SParams{i}.exclude(true)
                    end
                end
            end
        end
        
        function name = getName(obj)
            name = obj.rName;
        end
    end
end

