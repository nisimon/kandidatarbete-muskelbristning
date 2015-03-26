classdef MeasPathContainer
    % MEASPATHCONTAINER Container class for an array of MeasPaths
    %   Uses a graphical constructor
    
    properties (Access = private)
        measPaths
    end
    
    methods
        function obj = MeasPathContainer(path)
            % Send the file_name and name to the function that returns the paths in
            % one cell array.
            cellPaths = MeasPathContainer.userInterface2(path);
            obj.measPaths = MeasPathContainer.cell2MeasPaths(cellPaths);
        end
        function paths = getMeasPaths(obj)
            paths = obj.measPaths;
        end
    end
    
    methods (Static)
        % A function that returns the paths in cells in cells.
        function path_cells = userInterface2(path)

            % Read contents of path
            listing = dir(path);

            % Find names of folders
            folderIdxs = find([listing.isdir] == 1);
            % Do not display '.' and '..'
            folderNames = {listing(folderIdxs(3:end)).name};

            % Opens a list dialog with the name of the folders. Choose which of them to
            % load data from. Press Ctrl to choose more than one.
            [s,v]=listdlg('PromptString','To select more than one, hold Ctrl:',...
                'SelectionMode','multiple',...
                'ListString',folderNames);

            % Add 2 to indexes to compensate for ignoring '.' and '..'
            s = s + 2;

            % Loops through all folders choosen from the list dialog
            a=1;
            for n=1:length(s)
                fullPath = strcat(path,filesep,listing(s(n)).name);
                % Check if the folder contains data or subfolders.
                if MeasPathContainer.hasSubFolder(fullPath)
                    path_cells{a}=MeasPathContainer.userInterface2(fullPath);
                else
                    path_cells{a}=fullPath;
                end
                a=a+1;
            end

        end

        % Function that puts the paths in one cell array.
        function paths1 = cell2MeasPaths(cellPaths)
            a=1;
            for n=1:length(cellPaths)
                if iscell(cellPaths{n})
                    p = cell2MeasPaths(cellPaths{n});
                    for j=1:length(p)
                        disp('hej');
                        paths1{a}=MeasPath(p{j});
                        a=a+1;
                    end
                else
                    paths1{a}=MeasPath(cellPaths{n});
                    a=a+1;
                end
            end
        end
        
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
    end    
end

