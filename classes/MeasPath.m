classdef MeasPath
    %MEASPATH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        path
    end
    
    methods
        function obj = MeasPath(p)
            obj.path = p;
        end
        
        function [numPoints, numDataFiles] = queryData(obj)
            currDir = pwd;
            cd(obj.path);

            files = dir;

            numDataFiles = length(files) - 2; % Do not count '.' and '..'

            fid = fopen(files(3).name, 'rb');
            %# Get file size.
            fseek(fid, 0, 'eof');
            fileSize = ftell(fid);
            frewind(fid);
            %# Read the whole file.
            data = fread(fid, fileSize, 'uint8');
            %# Count number of line-feeds, equal to number of data points
            numPoints = sum(data == 10);
            fclose(fid);

            cd(currDir)
        end
        
        function p = getPath(obj)
            p = obj.path;
        end
    end
    
end

