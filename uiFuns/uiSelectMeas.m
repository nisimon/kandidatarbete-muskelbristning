% This function is a user interface. It has two parameters, "file_path" that
% is a path that points to a folder that contains .txt files with format:
% "Name of folder"; "Path to folder"; "If the folder contains data or
% subfolders, 1 for containing subfolders, and 0 for containing
% data."; "nr".
% The parameter "name" is the name of the .txt files in the folder that
% file_path points to.
% The function returns paths to the choosen folders.

function paths = uiSelectMeas(path)

% A function that returns the paths in cells in cells.
    function path_cells = UserInterface2(path)
        
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
        
        % Add 3 to indexes to compensate for ignoring '.' and '..'
        s = s + 2;

        % Loops through all folders choosen from the list dialog
        a=1;
        for n=1:length(s)
            fullPath = strcat(path,filesep,listing(s(n)).name);
            % Check if the folder contains data or subfolders.
            if hasSubFolder(fullPath)
                path_cells{a}=UserInterface2(fullPath);
            else
                path_cells{a}=fullPath;
            end
            a=a+1;
        end
        
    end
    
% Function that puts the paths in one cell array.
    function paths1 = cell2Paths(cellPaths)
        a=1;
        for n=1:length(cellPaths)
            if iscell(cellPaths{n})
                p = cell2Paths(cellPaths{n});
                for j=1:length(p)
                    paths1{a}=p{j};
                    a=a+1;
                end
            else
                paths1{a}=cellPaths{n};
                a=a+1;
            end
        end
    end

    % Send the file_name and name to the function that returns the paths in
    % one cell array.
    cellPaths = UserInterface2(path);
    paths = cell2Paths(cellPaths);
end
    
    












