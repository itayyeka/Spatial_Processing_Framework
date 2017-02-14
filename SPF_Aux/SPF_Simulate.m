function [Results] = SPF_Simulate(AlgType,EnvironmentCfg,ScenarioCfg)
eval(['Results=SPF_' AlgType '_Simulate(EnvironmentCfg,ScenarioCfg);']);
end