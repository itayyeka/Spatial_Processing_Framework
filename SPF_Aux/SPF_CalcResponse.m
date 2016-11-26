function [Response] = SPF_CalcResponse(EnvironmentCfg,ScenarioCfg)
AngleVec=0:ScenarioCfg.DOA.res:(360-0.5*ScenarioCfg.DOA.res);
    TmpEnvCfg=EnvironmentCfg;
    TmpScCfg=ScenarioCfg;
    TmpScCfg.nSnapshots=1;
    TmpScCfg.Noise.Sigma=0;
    SensorsDistances=cellfun(...
        @(X) sqrt(sum(X.Position.^2)), ...
        TmpEnvCfg.SensorsCfg);
    maxSensorDistance=max(SensorsDistances);
    ExampleSourceDistance=1000*maxSensorDistance;
    ResponseMAT=zeros(numel(EnvironmentCfg.SensorsCfg),numel(AngleVec));
    for AngleID=1:numel(AngleVec)
        CurAngle=AngleVec(AngleID);
        TmpEnvCfg.SourcesCfg=TmpEnvCfg.SourcesCfg(1);
        TmpEnvCfg.SourcesCfg{1}.Position=...
            [...
            ExampleSourceDistance*cos(2*pi*CurAngle/360) ...
            ExampleSourceDistance*sin(2*pi*CurAngle/360) ...
            0 ...
            ];
        TmpEnvCfg.SourcesCfg{1}.Signal=...
            ones(size(TmpEnvCfg.SourcesCfg{1}.Signal));
        ResponseMAT(:,AngleID)=...
            cell2mat(...
            reshape(...
            SPF_PORAT91_GenInput(TmpEnvCfg,TmpScCfg),...
            [],1) ...
            );
    end
    ResponseMAT_AbsMAT=repmat(sum(abs(ResponseMAT)),size(ResponseMAT,1),1);
    ResponseMAT_Norm=ResponseMAT./ResponseMAT_AbsMAT;
    Response.MAT=ResponseMAT_Norm;
    Response.SensorCfg=EnvironmentCfg.SensorsCfg;
end

