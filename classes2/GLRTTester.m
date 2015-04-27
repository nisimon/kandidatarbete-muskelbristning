classdef GLRTTester < handle
    %GLRTTESTER Class to test the performance of the GLRT classifier
    %   Detailed explanation goes here
    
    properties
        glrtPath
        classes
        knownClasses
        goodSParams
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
        end
        
        function predClasses = looCrossValidate(obj)
            predClasses = zeros(size(obj.knownClasses));
            
            % TODO: Proper function for preallocating data matrix
            dataMatrix = [];
            for i = 1:length(obj.classes)
                procMeases = getProcMeases(obj.classes{i});
                for j = 1:length(procMeases)
                    dataMatrix = [dataMatrix...
                        vectorize(procMeases{j},obj.goodSParams)];
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
    end
    
end

