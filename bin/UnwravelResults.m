function [ output_args ] = UnwravelResults( ResultsDir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    results = LoadSimulationResults( ResultsDir );
    load('/Users/Chris/src/SOSLassoSimulations/data/AnnotatedData.mat');
    load('/Users/Chris/src/SOSLassoSimulations/data/ConditionIndex.mat');
    z = ConditionIndex.condition == results(1).condition & ...
        ConditionIndex.subject == num2str(results(1).subject);
    
end

