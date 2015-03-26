% Loads s-parameters from adress "path" and antennas s1 and s2
% Returns an array with two columns
% Column 1 is the frequency
% Column 2 is the complex S parameter

function [data] = loadData(path,s1,s2)

    currDir = pwd;
    cd(path);

    sParam = strcat('S',num2str(s1),'_',num2str(s2));
    fileName = strcat(sParam,'.m');
    fileContents = load(fileName);

    freq = fileContents(:,1);
    S = fileContents(:,2) + 1i.*fileContents(:,3);
    
    data = [freq S];

    cd(currDir);
end
