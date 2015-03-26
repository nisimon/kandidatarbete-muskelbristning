classdef Data
    %DATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        dataArray
        dataName
    end
    
    methods
        function obj = Data(path, s1, s2)
        % Loads S-parameters and name from path and antennas s1 and s2
        % Returns an array with two columns
        % Column 1 is the frequency
        % Column 2 is the complex S parameter
        
                pathComponents = strsplit(path,filesep);
                name = pathComponents(end);
                
                currDir = pwd;
                cd(path);

                sParam = strcat('S',num2str(s1),'_',num2str(s2));
                fileName = strcat(sParam,'.m');
                fileContents = load(fileName);

                freq = fileContents(:,1);
                S = fileContents(:,2) + 1i.*fileContents(:,3);

                obj.dataName = name;
                obj.dataArray = [freq S];

                cd(currDir);
        end
        
        function name = getName(obj)
            name = obj.dataName;
        end
        
        function freq = getFreq(obj)
            freq = obj.dataArray(:,1);
        end
        
        function trans = getTrans(obj)
            trans = 20*log10(abs(obj.dataArray(:,2)));
        end
    end
    
end

