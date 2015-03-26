% Returns number of files and number of data points of data from adress "name"

function [numPoints, numDataFiles]=queryData(path)
    currDir = pwd;
    cd(path);

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
