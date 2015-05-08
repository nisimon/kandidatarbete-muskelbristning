classdef UiHugePlot < handle
    %UIHUGEPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Measurement variables
        dataClass
        measments
        measNames
        measColors
        % Plot numPlots * numPlots S-parameters
        numPlots
        % Scroll variables
        x 
        y
        % UI elements
        popup
        btnUp
        btnDown
        btnLeft
        btnRight
        % Figure handle
        fig
        % Input parser
        p
        % Plotting function
        plotFunc
        yLabel
    end
    
    methods
        function obj = UiHugePlot(dataSets, varargin)
            % Parse input arguments
            obj.p = inputParser;
            defaultShowLegend = true;
            defaultClassColors = false;
            defaultVerbose = false;
            defaultNumPlots = 2;
            
            addOptional(obj.p,'showLegend',defaultShowLegend,@islogical);
            addOptional(obj.p,'classColors',defaultClassColors,@islogical);
            addOptional(obj.p,'verbose',defaultVerbose,@islogical);
            addOptional(obj.p,'numPlots',defaultNumPlots,@isnumeric);
            
            parse(obj.p,varargin{:});
            
            % Get measurements to plot
            obj.measments = {};
            obj.measNames = [];
            obj.measColors = {};
            for i=1:length(dataSets)
                dataSet = dataSets{i};
                if i == 1
                    obj.dataClass = class(dataSet);
                else
                    if ~strcmp(obj.dataClass,class(dataSet))
                        error('Must plot objects from same class')
                    end
                end
                switch class(dataSet)
                    % Get measurements and measurement names depending
                    % on the input class
                    case 'MClass'
                        newMeases = getProcMeases(dataSet);
                        newNames = strcat(getName(dataSet),...
                            ': ', getMeasNames(dataSet));
                    case 'Measurement'
                        newMeases = getAllMeas(dataSet);
                        repNames = strcat(getName(dataSet),...
                            ': ', getRepNames(dataSet));
                        procName = strcat(getName(dataSet),...
                            ': ', 'processed');
                        newNames = [repNames procName];
                    otherwise
                        error('No support for plotting class %s', obj.dataClass);
                end
                obj.measments = [obj.measments...
                            newMeases];
                obj.measNames = [obj.measNames...
                    newNames];
                % Generate colors for the measurements
                newColors = cell(size(newMeases));
                for j = 1:length(newColors)
                    r1 = 1 + sign(-mod(i,3)); % Red
                    g1 = 1 + sign(-mod(i+1,3)); % Green
                    b1 = 1 + sign(-mod(i+2,3)); % Blue
                    r = min(r1 + mod(j*0.2*g1 + j*0.2*b1,0.9),1);
                    g = min(g1 + mod(j*0.2*r1 + j*0.2*b1,0.9),1);
                    b = min(b1 + mod(j*0.2*r1 + j*0.2*g1,0.9),1);
                    newColors{j} = [r g b]; 
                end
                obj.measColors = [obj.measColors...
                    newColors];
            end
            
            obj.fig = figure('units','normalized','outerposition',[0 0.05 1 0.95]);

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
                
            % Create pop-up menu
            obj.popup = uicontrol('Style', 'popup',...
               'String', {'Amplitude [dB]','Amplitude','Phase'},...
               'Parent',obj.fig,...
               'Units', 'normalized',...
               'Position', [0 0.9 .1 .1],...
               'Callback', @obj.popupCallback);
           
           % Set default plotting function
           obj.plotFunc = @getdBData;
           obj.yLabel = 'Amplitud [dB]';
           
           % Disable warnings if not in verbose mode
           if ~obj.p.Results.verbose
               warning('off','HugePlot:subplot:SParamFail');
               warning('off','MATLAB:legend:PlotEmpty');
           end
           
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
            if (newX >= 0)
                obj.x = newX;
            end

            % Disable and enable scroll buttons
            if (newX <= 0)
                set(obj.btnLeft, 'enable', 'off')
                set(obj.btnRight, 'enable', 'on')
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
            if (newY >= 0)
                obj.y = newY;
            end

            % Disable and enable scroll buttons
            if (newY <= 0)
                set(obj.btnUp, 'enable', 'off')
                set(obj.btnDown, 'enable', 'on')
            else
                set(obj.btnUp, 'enable', 'on')
                set(obj.btnDown, 'enable', 'on')            
            end

            % Redraw plots
            redraw(obj);
        end  
        
        function popupCallback(obj,srcHandle,eventData)
            val = get(srcHandle,'Value');
            disp(val);
            switch val
                case 1
                    obj.plotFunc = @getdBData;
                    obj.yLabel = 'Amplitud [dB]';
                case 2
                    obj.plotFunc = @getAmplData;
                    obj.yLabel = 'Amplitud';
                case 3
                    obj.plotFunc = @getPhaseData;
                    obj.yLabel = 'Fas [radianer]';
            end
            redraw(obj);
        end
        
        function redraw(obj)
        % Function to draw plots
            for i=1:obj.p.Results.numPlots
                for j=1:obj.p.Results.numPlots
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
                            warning('HugePlot:subplot:SParamFail',...
                                'Problem loading S-parameter %s ',...
                                SParam);
                        end
                    end

                    % Select and clear the correct subplot
                    currPlot = (i-1)*obj.p.Results.numPlots + j;
                    sp = subplot(obj.p.Results.numPlots,obj.p.Results.numPlots,currPlot);
                    cla(sp);
                    hold on;
                    xlabel('Frekvens [Hz]');
                    ylabel(obj.yLabel);
                    title(strcat('S',num2str(s1),'\_',num2str(s2)));

                    % Draw measurements in subplot
                    for k=1:length(meas)
                        if ~isempty(meas{k})
                            xData = getFreq(meas{k});

                            % Plot data using chosen function
                            yData = obj.plotFunc(meas{k});

                            % Get a color for the line
                            color = obj.measColors{k};
                            
                            % Dash line if measurement is excluded
                            if isExcluded(meas{k})
                                linespec = '--';
                            else
                                linespec = '-';
                            end
                            if obj.p.Results.classColors
                                plot(xData,yData,linespec,'Color',color);
                            else
                                plot(xData,yData,linespec);
                            end
                        end
                    end
                    
                    %Create legend
                    if obj.p.Results.showLegend &&...
                            length(obj.measNames) >= 1
                        legend(obj.measNames(~cellfun('isempty', meas)),...
                            'Interpreter','none','Location','best');
                    end
                end
            end
        end
    end
    
end

