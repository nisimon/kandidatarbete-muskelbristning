classdef UiHugePlot < handle
    %UIHUGEPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataSet
        % There are n*n s-parameters
        n
        % Plot numPlots * numPlots S-parameters
        numPlots
        % Scroll variables
        x 
        y
        % Buttons
        btnUp
        btnDown
        btnLeft
        btnRight
        % Figure handle
        fig
    end
    
    methods
        function obj = UiHugePlot(dataSet)
            obj.dataSet = dataSet;
            obj.fig = figure('units','normalized','outerposition',[0 0.05 1 0.95]);
            obj.numPlots = 2;

            % There are n*n s-parameters
            obj.n = getN(dataSet);

            % Scroll variables
            obj.x = 0;
            obj.y = 0;

            % Create buttons
            obj.btnLeft = uicontrol('Style', 'pushbutton', 'String', '<',...
                    'Parent',obj.fig,...
                    'Units', 'normalized',...
                    'Position', [0 0.4 0.02 0.2],...
                    'Callback', @obj.scrollCallback,...
                    'enable', 'off'); 
            obj.btnRight = uicontrol('Style', 'pushbutton', 'String', '>',...
                    'Parent',obj.fig,...
                    'Units', 'normalized',...
                    'Position', [0.98 0.4 0.02 0.2],...
                    'Callback', @obj.scrollCallback);
            obj.btnUp = uicontrol('Style', 'pushbutton', 'String', '^',...
                    'Parent',obj.fig,...
                    'Units', 'normalized',...
                    'Position', [0.4 0.96 0.2 0.04],...
                    'Callback', @obj.scrollCallback,...
                    'enable', 'off'); 
            obj.btnDown = uicontrol('Style', 'pushbutton', 'String', 'v',...
                    'Parent',obj.fig,...
                    'Units', 'normalized',...
                    'Position', [0.4 0 0.2 0.04],...
                    'Callback', @obj.scrollCallback);
            redraw(obj);
        end
        % Scroll functions
        
        function scrollCallback(obj,srcHandle,eventData)
            if srcHandle == obj.btnUp
                scrollY(obj,-1);
            elseif srcHandle == obj.btnDown
                scrollY(obj,1);
            elseif srcHandle == obj.btnLeft
                scrollX(obj,-1);
            elseif srcHandle == obj.btnRight
                scrollX(obj,1);
            end
        end
        
        function scrollX(obj, value)
            % Calculate and if possible set new x value
            newX = obj.x + value;
            if (newX >= 0 && newX <= obj.n - obj.numPlots)
                obj.x = newX;
            end

            % Disable and enable scroll buttons
            if (newX <= 0)
                set(obj.btnLeft, 'enable', 'off')
                set(obj.btnRight, 'enable', 'on')
            elseif (newX >= obj.n - obj.numPlots)
                set(obj.btnLeft, 'enable', 'on')
                set(obj.btnRight, 'enable', 'off')
            else
                set(obj.btnLeft, 'enable', 'on')
                set(obj.btnRight, 'enable', 'on')            
            end

            % Redraw plots
            redraw(obj);
        end

        function scrollY(obj, value)
            % Calculate and if possible set new y value
            newY = obj.y + value;
            if (newY >= 0 && newY <= obj.n - obj.numPlots)
                obj.y = newY;
            end

            % Disable and enable scroll buttons
            if (newY <= 0)
                set(obj.btnUp, 'enable', 'off')
                set(obj.btnDown, 'enable', 'on')
            elseif (newY >= obj.n - obj.numPlots)
                set(obj.btnUp, 'enable', 'on')
                set(obj.btnDown, 'enable', 'off')
            else
                set(obj.btnUp, 'enable', 'on')
                set(obj.btnDown, 'enable', 'on')            
            end

            % Redraw plots
            redraw(obj);
        end  
        
        function redraw(obj)
        % Function to draw plots
            for i=1:obj.numPlots
                for j=1:obj.numPlots
                    % Calculate which S-parameters to draw
                    s1 = obj.y + i;
                    s2 = obj.x + j;
                    SParam = cellstr(strcat('S',num2str(s1),'_',num2str(s2)));

                    % Get array of measurements
                    meas = getMeas(obj.dataSet, SParam);

                    % Select and clear the correct subplot
                    currPlot = (i-1)*obj.numPlots + j;
                    sp = subplot(obj.numPlots,obj.numPlots,currPlot);
                    cla(sp);
                    hold on;

                    % Draw measurements in subplot
                    for k=1:length(meas)
                        xData = getFreq(meas{k});

                        %Add multiple modes for plotting data
                        yData = getTrans(meas{k});

                        % Create a color for the line
                        color = [mod(k*0.3,1) mod(k*0.2,1) mod(k*0.7,1)];
                        plot(xData,yData,'Color',color);
                        title(strcat('S',num2str(s1),'\_',num2str(s2)));
                    end

                    % Create legend
%                     legend([dataSet(sIdx).meas.name],...
%                         'Interpreter','none','Location','best');
                end
            end
        end
    end
    
end

