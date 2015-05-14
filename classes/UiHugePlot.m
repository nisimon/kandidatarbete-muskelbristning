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
        % Plot colors (MATLAB default colors)
        col=[0    0.4470    0.7410;
            0.8500    0.3250    0.0980;
            0.9290    0.6940    0.1250;
            0.4940    0.1840    0.5560;
            0.4660    0.6740    0.1880;
            0.3010    0.7450    0.9330;
            0.6350    0.0780    0.1840];
    end
    
    methods
        function obj = UiHugePlot(dataSets, varargin)
            % Parse input arguments
            obj.p = inputParser;
            defaultShowReps = true;
            defaultShowExcluded = true;
            defaultShowLegend = true;
            defaultClassColors = false;
            defaultVerbose = false;
            defaultNumPlots = 2;
            
            addOptional(obj.p,'showReps',defaultShowReps,@islogical);
            addOptional(obj.p,'showExcluded',defaultShowExcluded,@islogical);
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
                        if obj.p.Results.showReps
                            newMeases = getAllMeas(dataSet);
                            repNames = strcat(getName(dataSet),...
                                ': ', getRepNames(dataSet));
                            procName = strcat(getName(dataSet),...
                                ': ', 'processed');
                            newNames = [repNames procName];
                        else
                            newMeases = {getProcMeas(dataSet)};
                            newNames = {getName(dataSet)};
                        end
                    case 'cell'
                        newMeases = cell(1,length(dataSet));
                        newNames = cell(1,length(dataSet));
                        for j = 1:length(newMeases);
                            newMeases{j} = getProcMeas(dataSet{j});
                            newNames{j} = getName(dataSet{j});
                        end
                    otherwise
                        error('No support for plotting class %s', obj.dataClass);
                end
                obj.measments = [obj.measments...
                            newMeases];
                obj.measNames = [obj.measNames...
                    newNames];
                % Select colors for the measurements
                newColors = cell(size(newMeases));
                for j = 1:length(newColors)
                    newColors{j} = obj.col(mod(i,7)+1,:); 
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
               'String', {'Amplitude [dB]','Amplitude','Phase','Real part'},...
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
           else
               warning('on','HugePlot:subplot:SParamFail');
               warning('on','MATLAB:legend:PlotEmpty');
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
                case 4
                    obj.plotFunc = @getRealData;
                    obj.yLabel = 'Realdel';
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
                        catch E
                            warning('HugePlot:subplot:SParamFail',...
                                'Problem loading S-parameter %s: %s ',...
                                SParam, E.message);
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
                        if ~isempty(meas{k}) &&...
                            (obj.p.Results.showExcluded ||...
                            ~obj.p.Results.showExcluded && ~isExcluded(meas{k}))
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
                    if length(obj.measNames) >= 1
                        leg = legend(obj.measNames(~cellfun('isempty', meas)),...
                                'Interpreter','none','Location','best');
                        if ~obj.p.Results.showLegend
                            set(leg, 'visible', 'off');
                        end
                    end
                end
            end
        end
    end 
end