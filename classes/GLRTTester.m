classdef GLRTTester < handle
    %GLRTTESTER Class to test the performance of the GLRT classifier
    %   Detailed explanation goes here
    
    properties
        glrtPath
        classes
        knownClasses
        goodSParams
        classingFreq
    end
    
    methods
        function obj = GLRTTester(classes)
            obj.glrtPath = uigetdir('', 'Select directory of file glrt.p');
            addpath(obj.glrtPath);
            obj.classes = classes;
            obj.knownClasses = [];
            for i = 1:length(classes)
                obj.knownClasses = [obj.knownClasses...
                    i*ones(1,getNumMeases(classes{i}))];
            end
            obj.goodSParams = cell(0);
            obj.classingFreq = [];
        end
        
        function predClasses = looCrossValidate(obj)
            predClasses = zeros(size(obj.knownClasses));
            
            if ~isempty(obj.goodSParams)
                % Prioritize specified S-parameters
                vectSParams = obj.goodSParams;
            else
                % Find names of S-parameters included in all measurements
                vectSParams = getIncSParams(obj);
            end
            
            disp(vectSParams);
            
            % TODO: Proper function for preallocating data matrix
            dataMatrix = [];
            for i = 1:length(obj.classes)
                procMeases = getProcMeases(obj.classes{i});
                for j = 1:length(procMeases)
                    dataMatrix = [dataMatrix...
                        vectorize(procMeases{j},vectSParams,obj.classingFreq)];
                end
            end
            
            % LOO loop
            for i = 1:length(predClasses)
                x = dataMatrix(:,i);
                data = dataMatrix(:,[1:(i-1) (i+1):end]);
                
                tempClasses = obj.knownClasses([1:(i-1) (i+1):end]);
                finalClass = tempClasses(end);
                idxColumns = zeros(1,finalClass);
                
                for j = 1:length(idxColumns)
                    idxColumns(j) = sum(tempClasses == j);
                end
                
                class =...
                    glrt(x, 'Alldata', data, 'indAll', idxColumns);
                
                predClasses(i) = class;
            end
        end
        
        function knownClasses = getKnownClasses(obj)
            knownClasses = obj.knownClasses;
        end
        
        function [] = setGoodSParams(obj,goodSPs)
            obj.goodSParams = goodSPs;
        end
        
        function [] = setClassingFreq(obj,classingFreq)
            obj.classingFreq = classingFreq;
        end
        
        function incSParams = getIncSParams(obj)
            % Find names of S-parameters included in all measurements
            incSParams = {};
            for i = 1:length(obj.classes)
                procMeases = getProcMeases(obj.classes{i});
                for j = 1:length(procMeases)
                    if isempty(incSParams)
                        incSParams =...
                            getIncludedSPNames(procMeases{j});
                    else
                        incSParams = intersect(incSParams,...
                            getIncludedSPNames(procMeases{j}));
                    end
                end
            end
        end
        
        function SPScores = scoreSParams(obj)
            incSParams = getIncSParams(obj);
            emptyCells = cell(size(incSParams));
            
            SPScores = struct('name',emptyCells,'score',emptyCells);
            
            oldGoodSParams = obj.goodSParams;
            
            for i = 1:length(incSParams)
                currSP = incSParams{i};
                SPScores(i).name = currSP;
                
                setGoodSParams(obj,{currSP});
                
                predClasses = looCrossValidate(obj);
                
                SPScores(i).score = sum(predClasses == obj.knownClasses);
            end
            
            setGoodSParams(obj,oldGoodSParams);
        end
    end
    
end

