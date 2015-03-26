function name = getName( path )
%GETNAME Returns name of measurement in path
%   The name is the name of the top directory in the path

    pathComponents = strsplit(path,filesep);
    name = pathComponents(end);

end

