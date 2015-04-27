classdef SParam < handle
    %SPARAM Class containing the data of an S-parameter
    %   Can be constructed from either a struct of data or a data file
    %   Contains methods to get the data in different forms
    
    properties
        isexcluded
        SName
        dataArray
    end
    
    methods
        function obj = SParam(indata)
            if isstruct(indata)
                % Construct an S-parameter from a struct of data
                obj.SName = indata.name;
                obj.dataArray = [indata.freq indata.S]; 
            else
                % Construct an S-parameter from the path to a data file
                if isdir(indata)
                    error('Must specify path to data file');
                end

                % Get name for S-parameter
                % Same as filename without extension
                pathComponents = strsplit(indata,filesep);
                fileName = pathComponents{end};
                tempName = strsplit(fileName,'.');
                tempName = tempName(1);

                % Load data from file
                fileContents = load(indata);

                freq = fileContents(:,1);
                S = fileContents(:,2) + 1i.*fileContents(:,3);

                obj.SName = tempName{1};
                obj.dataArray = [freq S];
            end

            obj.isexcluded = false;
        end
        
        function [] = exclude(obj,tf)
            obj.isexcluded = tf;
        end
        
        function name = getName(obj)
            name = obj.SName;
        end
        
        function freq = getFreq(obj)
            freq = obj.dataArray(:,1);
        end
        
        function trans = getdBData(obj)
        % Gets the amplitude of the S-parameter in dB
            trans = 20*log10(abs(obj.dataArray(:,2)));
        end
        
        function complex = getComplexData(obj)
        % Gets the raw complex data of the S-parameter
            complex = obj.dataArray(:,2);
        end
    end
    
end

