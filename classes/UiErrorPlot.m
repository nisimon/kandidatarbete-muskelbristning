classdef UiErrorPlot < handle
    %UIERRORPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Data structure
        dataStruct
        % Plot numPlots * numPlots S-parameters
        numPlots
        % Scroll variables
        x 
        y
        % UI elements
        btnUp
        btnDown
        btnLeft
        btnRight
        % Figure handle
        fig
        % Input parser
        p
    end
    
    methods
        function obj = UiErrorPlot(dataStruct, varargin)
            % Parse input arguments
            obj.p = inputParser;
            defaultShowLegend = true;
            defaultVerbose = false;
            defaultNumPlots = 2;
            
            addOptional(obj.p,'showLegend',defaultShowLegend,@islogical);
            addOptional(obj.p,'verbose',defaultVerbose,@islogical);
            addOptional(obj.p,'numPlots',defaultNumPlots,@isnumeric);
            
            parse(obj.p,varargin{:});
            
            % Get data to plot
            obj.dataStruct = dataStruct;
            
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
           
           % Disable warnings if not in verbose mode
           if ~obj.p.Results.verbose
               warning('off','ErrorPlot:subplot:SParamFail');
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
        
        function redraw(obj)
        % Function to draw plots
            for i=1:obj.p.Results.numPlots
                for j=1:obj.p.Results.numPlots
                    % Calculate which S-parameter to draw
                    s1 = obj.y + i;
                    s2 = obj.x + j;
                    SParam = strcat('S',num2str(s1),'_',num2str(s2));

                    % Get S-parameter from data structure
                    currSP =...
                        obj.dataStruct(strcmp({obj.dataStruct.name},...
                        SParam));

                    % Select and clear the correct subplot
                    currPlot = (i-1)*obj.p.Results.numPlots + j;
                    sp = subplot(obj.p.Results.numPlots,obj.p.Results.numPlots,currPlot);
                    cla(sp);
                    hold on;
                    xlabel('Frekvens [Hz]');
                    ylabel('Amplitud [dB]');
                    title(strcat('S',num2str(s1),'\_',num2str(s2)));
                    
                    if ~isempty(currSP)
                        % Get array of measurements and names
                        measNames = cell(1,length(currSP.devs));
                        for k = 1:length(currSP.devs)
                            % Draw measurements in subplot
                            plot(currSP.freq,...
                                currSP.devs(k).mean);
                            errorbar(currSP.freq(1+2*k:20:end),...
                                currSP.devs(k).mean(1+2*k:20:end),...
                                currSP.devs(k).dev(1+2*k:20:end),...
                                '+');
                            measNames{k} = currSP.devs(k).className;
                        end
                        %Create legend
                        if obj.p.Results.showLegend
                            legend(measNames,...
                                'Interpreter','none','Location','best');
                        end
                    else
                        warning('ErrorPlot:subplot:SParamFail',...
                                'Problem loading S-parameter %s ',...
                                SParam);
                    end
                end
            end
        end
    end
end

