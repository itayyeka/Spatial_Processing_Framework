function [] = SPF_Main(PRESET_SimCfg)
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
    for AlgID=1:numel(SimCfg.Algorithms)
        CurAlgType=SimCfg.Algorithms{AlgID};
        for ScnID=1:numel(SimCfg.Scenarios)
            CurScenarioCfg=SimCfg.Scenarios{ScnID};
            SimResults.(CurAlgType).Environemts{EnvID}.Scenarios{ScnID}=...
                SPF_Simulate(CurAlgType,CurEnvironmentCfg,CurScenarioCfg);
        end
    end
end
save('SimResults.mat','SimResults');
end
