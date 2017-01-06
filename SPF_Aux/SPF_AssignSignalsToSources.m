function [SourcesCfg] = SPF_AssignSignalsToSources(SourcesCfg,ScenarioCfg)
nSrc=numel(SourcesCfg);
if strcmpi(ScenarioCfg.Sources.SignalType,'CW')
    %{
    The complex envelope of CW signals is constant. without loss of
    generality, it can be ones...
    %}
    for SrcID=1:nSrc
        SourcesCfg{SrcID}.Signal=ones(ScenarioCfg.nSnapshots,1);
    end
elseif strcmpi(ScenarioCfg.Sources.SignalType,'QAM')
    AmpOpt=-3:2:3;
    nOpt=length(AmpOpt);
    for SrcID=1:nSrc
        SourcesCfg{SrcID}.Signal=...
            reshape(...
            AmpOpt(randi(nOpt,ScenarioCfg.nSnapshots,1)) ...
            + ...
            1i*AmpOpt(randi(nOpt,ScenarioCfg.nSnapshots,1)) ...
            ,[],1 ...
            );
    end
else
    assert('signal type not implemented yet');
end
end