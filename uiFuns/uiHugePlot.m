% Plot numPlots*numPlots S-parameters with the ability to scroll between
% different parameters

function [] = uiHugePlot(xDataSet, yDataSet, measNames, numPlots)
    fig = figure('units','normalized','outerposition',[0 0.05 1 0.95]);
    
    % There are n*n s-parameters and num measurements of each
    dataSize = size(xDataSet);
    n = dataSize(1);
    numMeas = dataSize(4);
    
    % Scroll variables
    x = 0;
    y = 0;

    % Function to draw plots
    function [] = redraw()
        for i=1:numPlots
            for j=1:numPlots
                % Calculate which S-parameters to draw
                s1 = y + i;
                s2 = x + j;
                
                % Select and clear the correct subplot
                currPlot = (i-1)*numPlots + j;
                cla(subplot(numPlots,numPlots,currPlot));
                hold on;
                
                % Draw measurements in subplot
                for k=1:numMeas
                    xData = squeeze(xDataSet(s1,s2,:,k));
                    yData = squeeze(yDataSet(s1,s2,:,k));
                    % Create a color for the line
                    color = [mod(k*0.3,1) mod(k*0.2,1) mod(k*0.7,1)];
                    plot(xData,yData,'Color',color);
                    title(strcat('S',num2str(s1),'\_',num2str(s2)));
                end
                
                % Create legend
                if ~isempty(measNames) && currPlot == 1
                    legend(measNames,'Interpreter','none','Location','best');
                end
            end
        end
    end

    % Create buttons
    btnLeft = uicontrol('Style', 'pushbutton', 'String', '<',...
            'Units', 'normalized',...
            'Position', [0 0.4 0.02 0.2],...
            'Callback', {@scrollX,-1},...
            'enable', 'off'); 
    btnRight = uicontrol('Style', 'pushbutton', 'String', '>',...
            'Units', 'normalized',...
            'Position', [0.98 0.4 0.02 0.2],...
            'Callback', {@scrollX,1});
    btnUp = uicontrol('Style', 'pushbutton', 'String', '^',...
            'Units', 'normalized',...
            'Position', [0.4 0.96 0.2 0.04],...
            'Callback', {@scrollY,-1},...
            'enable', 'off'); 
    btnDown = uicontrol('Style', 'pushbutton', 'String', 'v',...
            'Units', 'normalized',...
            'Position', [0.4 0 0.2 0.04],...
            'Callback', {@scrollY,1});

    % Scroll functions
    function [newX] = scrollX(hObject, callbackdata, value)
        % Calculate and if possible set new x value
        newX = x + value;
        if (newX >= 0 && newX <= n - numPlots)
            x = newX;
        end
        
        % Disable and enable scroll buttons
        if (newX <= 0)
            set(btnLeft, 'enable', 'off')
            set(btnRight, 'enable', 'on')
        elseif (newX >= n - numPlots)
            set(btnLeft, 'enable', 'on')
            set(btnRight, 'enable', 'off')
        else
            set(btnLeft, 'enable', 'on')
            set(btnRight, 'enable', 'on')            
        end
        
        % Redraw plots
        redraw();
    end

    function [newY] = scrollY(hObject, callbackdata, value)
        % Calculate and if possible set new y value
        newY = y + value;
        if (newY >= 0 && newY <= n - numPlots)
            y = newY;
        end
        
        % Disable and enable scroll buttons
        if (newY <= 0)
            set(btnUp, 'enable', 'off')
            set(btnDown, 'enable', 'on')
        elseif (newY >= n - numPlots)
            set(btnUp, 'enable', 'on')
            set(btnDown, 'enable', 'off')
        else
            set(btnUp, 'enable', 'on')
            set(btnDown, 'enable', 'on')            
        end
        
        % Redraw plots
        redraw();
    end    
    
    redraw();
end
