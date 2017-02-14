function [SimResults] = SPF_Main(PRESET_SimCfg)
global SPF_FLAGS;
close all;
clc;
[FuncPath,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(FuncPath,'SPF_Aux')));
%% SimCfg
SimCfg=PRESET_SimCfg;
%% Simulate
SimResults={};
for EnvID=1:numel(SimCfg.Environments)
    CurEnvironmentCfg=SimCfg.Environments{EnvID};
    if SPF_FLAGS.VERBOSE
        SPF_PlotEnvironment(CurEnvironmentCfg);
        close all;
    end
    SimResults.Environemts{EnvID}.EnvironmentCfg=CurEnvironmentCfg;
    for ScnID=1:numel(SimCfg.Scenarios)
        CurScenarioCfg=SimCfg.Scenarios{ScnID};
        SimResults.Environemts{EnvID}.Scenarios{ScnID}.ScenarioCfg=CurScenarioCfg;
        for AlgID=1:numel(SimCfg.Algorithms)
            CurAlgType=SimCfg.Algorithms{AlgID};
            for SeedID=1:numel(SimCfg.Seeds)
                CurSeed=SimCfg.Seeds{SeedID};
                rng('default');
                rng(CurSeed);
                SimResults.Environemts{EnvID}.Scenarios{ScnID}.Seeds{SeedID}.Seed=CurSeed;
                SimResults.Environemts{EnvID}.Scenarios{ScnID}.Seeds{SeedID}.(CurAlgType)=...
                    SPF_Simulate(CurAlgType,CurEnvironmentCfg,CurScenarioCfg);
            end
        end
    end
end
end