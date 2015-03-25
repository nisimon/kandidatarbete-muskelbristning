function hasSubFolder = hasSubFolder( path )
%HASSUBFOLDER Returns 1 if the path has any subfolders

    dirContents = dir(path);

    % Count number of subfolders
    s = 0;
    for n = 1:length(dirContents)
        s = s + dirContents(n).isdir;
    end

    % Do not count '.' and '..'
    if s>2
        hasSubFolder = 1;
    else
        hasSubFolder = 0;
    end

end

