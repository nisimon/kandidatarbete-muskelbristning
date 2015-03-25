% Loads s-parameters from adress "path" and antennas s1 and s2

function [trans,phase,freq] = loadData(path,s1,s2)

    currDir = pwd;
    cd(path);

    sParam = strcat('S',num2str(s1),'_',num2str(s2));
    fileName = strcat(sParam,'.m');
    load(fileName);

    freq = eval(strcat(sParam,'(:,1)'));
    phase = eval(strcat('angle(',sParam,'(:,2)+i*',sParam,'(:,3));'));
    trans = eval(strcat('sqrt(',sParam,'(:,2).^2+',sParam,'(:,3).^2);'));
    trans = 20*log10(trans);
    phase = unwrap(phase);

    cd(currDir);
end
