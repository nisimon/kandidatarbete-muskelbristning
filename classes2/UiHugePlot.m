classdef UiHugePlot < handle
    %UIHUGEPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataClass
        measments
        measNames
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
            obj.dataClass = class(dataSet);
            switch class(dataSet)
                case 'MClass'
                    obj.n = getN(dataSet);
                    obj.measments = getProcMeases(dataSet);
                    obj.measNames = getMeasNames(dataSet);
                case 'Measurement'
                    obj.n = getN(dataSet);
                    obj.measments = getAllMeas(dataSet);
                    repNames = getRepNames(dataSet);
                    obj.measNames = [repNames 'Processed'];
                otherwise
                    error('No support for plotting class %s', obj.dataClass);
            end
            
            obj.fig = figure('units','normalized','outerposition',[0 0.05 1 0.95]);
            obj.numPlots = 2;

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
                    % Calculate which S-parameter to draw
                    s1 = obj.y + i;
                    s2 = obj.x + j;
                    SParam = strcat('S',num2str(s1),'_',num2str(s2));

                    % Get array of measurements
                    meas = cell(1,length(obj.measments));
                    for k = 1:length(meas)
                        try
                            SP = getSParams(obj.measments{k}, {SParam});
                            meas{k} = SP{1};
                        catch
                            warning('Problem loading S-parameter %s ',...
                                SParam);
                        end
                    end

                    % Select and clear the correct subplot
                    currPlot = (i-1)*obj.numPlots + j;
                    sp = subplot(obj.numPlots,obj.numPlots,currPlot);
                    cla(sp);
                    hold on;
                    title(strcat('S',num2str(s1),'\_',num2str(s2)));

                    % Draw measurements in subplot
                    for k=1:length(meas)
                        if ~isempty(meas{k})
                            xData = getFreq(meas{k});

                            %Add multiple modes for plotting data
                            yData = getdBData(meas{k});

                            % Create a color for the line
                            color = [mod(k*0.3,1) mod(k*0.2,1) mod(k*0.7,1)];
                            
                            % Dash line if measurement is excluded
                            if isExcluded(meas{k})
                                linespec = '--';
                            else
                                linespec = '-';
                            end
                            plot(xData,yData,linespec,'Color',color);
                        end
                    end
                    
                    %measIdxs = find(~cellfun('isempty', meas));
                    %Create legend
                    if length(obj.measNames) >= 1
                        legend(obj.measNames(~cellfun('isempty', meas)),...
                            'Interpreter','none','Location','best');
                    end
                end
            end
        end
    end
    
end
