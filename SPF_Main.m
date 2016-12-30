function [] = SPF_Main(PRESET_SimCfg)
close all;
clc;
global SPF_FLAGS;
SPF_FLAGS=[];
SPF_FLAGS.VERBOSE=1;
[FuncPath,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(FuncPath,'SPF_Aux')));
%% SimCfg
if nargin==0
    %{
    Standalone configuration:
    To have multiple simultions without the need of changing the code, one
    can Create a wrapper to the SPF_Main function and insert a PRESET
    configuration.
    %}
    if true
        %% Algorithms
        SimCfg.Algorithms={...
            ... 'CHECK' ...
            'PORAT91_A' ...
            ...'NESTED_P2' ...
            };
        %% Environments
        %{
    Units:
    distance    - meters.
    Angle       - Radians.
    Time        - Seconds.
    Frequency   - Periods/seconds
    Speed       - meters/seconds
    
    The simulation is a 3d simulation that handles 3 axis:
    X - The right/left from the simulation point of view (positive-right
    and negative-left)
    Y - The forward/backward from the simulation point of view (positive-forward
    and negative-backward)
    Z - The up/down from the simulation point of view (positive-up
    and negative-down)
    
    As a general rule, all locations of sources/sensors will be relative to
    a reference point that will be the (X,Y,Z)=(0,0,0).
   
    When angles are configured (angle of an array of sensors/surces) there
    will be two angles to provide:
    phi - The horizontal angle that will be measured from the posistive y
    axis (forward).
    phi{(X,Y,Z)=(0,1,0)} =  0
    phi{(X,Y,Z)=(1,0,0)} = -pi/2
    phi{(X,Y,Z)=(-1,0,0)}=  pi/2
    phi{(X,Y,Z)=(0,-1,0)}=  pi
    Theta - The vertical angle that will be easured from the horizon (Z=0)
    to the upper (postive Z) vertical direction.
    Theta{(X,Y,Z)=(1,0,0)} =  0
    Theta{(X,Y,Z)=(0,1,0)} =  0
    Theta{(X,Y,Z)=(0,0,1)} =  pi/2
    Theta{(X,Y,Z)=(0,0,-1)}= -pi/2
    
    Therefore:
    if D is the Distance,
    x = D*Cos(Theta)*Cos(Phi)
    y = D*Cos(Theta)*Sin(Phi)
    z = D*Sin(Theta)
        %}
        SimCfg.Environments={};
        if true
            %% Environment1
            EnvironmentCfg=[];
            if true
                %{
            Configurable parameters for sources/sensors are:
            
            Position -
            vector of 3 elements (X,Y,Z)
            the center position (X,Y,Z) of the source/sensors array.
 
            Distnace -
            Instead of configuring the center, one can define its
            distance from the the reference point. When configuring
            Distance, one can also define Theta and Phi.
            
            Phi -
            When configuring Distance
            
            Theta -
            When configuring Distance
            
            Shape -
            String.
            As the simulator will grow, more and more shapes of
            sources/sensors will be supported (Single,ula,sphere,ball,swarm,
            circle etc...)
            
            ShapeCfg -
            Record:
            * ShapeCfg.Size -   the distance between the two most
                        distant sources/sensors in the array.
            * ShapeCfg.Orientation.Phi
            * ShapeCfg.Orientation.Theta
                %}
                %% Sources
                EnvironmentCfg.SourcesCfg={};
                EnvironmentCfg.Arrays={};
                if true
                    %% SourceCfg1
                    SourceCfg=[];
                    if true
                        %% Source parameters
                        SourceCfg.Distance=100;
                        SourceCfg.Phi=f_convert_deg_to_rad(70);
                        SourceCfg.Theta=0;
                    end
                    EnvironmentCfg.SourcesCfg=...
                        SPF_AddElements(EnvironmentCfg.SourcesCfg,SourceCfg);
                    %% SourceCfg2
                    SourceCfg=[];
                    if true
                        %% Source parameters
                        SourceCfg.Distance=100;
                        SourceCfg.Phi=f_convert_deg_to_rad(40);
                        SourceCfg.Theta=0;
                    end
                    %                 EnvironmentCfg.SourcesCfg=...
                    %                     SPF_AddElements(EnvironmentCfg.SourcesCfg,SourceCfg);
                    %% SourceCfg3
                    SourceCfg=[];
                    if true
                        %% Source parameters
                        SourceCfg.Distance=100;
                        SourceCfg.Phi=f_convert_deg_to_rad(10);
                        SourceCfg.Theta=0;
                    end
                    %                 EnvironmentCfg.SourcesCfg=...
                    %                     SPF_AddElements(EnvironmentCfg.SourcesCfg,SourceCfg);
                    %% ...
                end
                %% Sensors
                EnvironmentCfg.SensorsCfg={};
                if true
                    %% SensorCfg1
                    SensorCfg=[];
                    if true
                        %% Sensor parameters
                        SensorCfg.Distance=0;
                        SensorCfg.Phi=0;
                        SensorCfg.Theta=0;
                        SensorCfg.Shape='NESTED_ARRAYS_sensors';
                        SensorCfg.ShapeCfg.nElements=9;
                        SensorCfg.ShapeCfg.ULAs_AngleVEC_DEG=[45 -45];
                        SensorCfg.ShapeCfg.Size=[];
                        SensorCfg.ShapeCfg.DenseElementsSpacing=0.01;
                        SensorCfg.ShapeCfg.SparseElementsSpacing=...
                            3*SensorCfg.ShapeCfg.DenseElementsSpacing;
                        SensorCfg.ShapeCfg.Orientation.Phi=0;
                        SensorCfg.ShapeCfg.Orientation.Theta=0;
                    end
                    EnvironmentCfg.Arrays{end+1}.Cfg=SensorCfg;
                    EnvironmentCfg.Arrays{end}.Sensors=...
                        SPF_AddElements({},SensorCfg);
                    EnvironmentCfg.SensorsCfg=...
                        SPF_AddElements(EnvironmentCfg.SensorsCfg,SensorCfg);
                    %% SensorCfg2
                    SensorCfg=[];
                    if true
                        %% Sensor parameters
                        ElementsSpacing=0.01;
                        SensorCfg.Distance=2.5*ElementsSpacing/2;
                        SensorCfg.Phi=3*pi/4;
                        SensorCfg.Theta=0;
                        SensorCfg.Shape='ula';
                        SensorCfg.ShapeCfg.nElements=4;
                        SensorCfg.ShapeCfg.Size=...
                            (SensorCfg.ShapeCfg.nElements-1)*ElementsSpacing/2;
                        SensorCfg.ShapeCfg.Orientation.Phi=-3*pi/4;
                        SensorCfg.ShapeCfg.Orientation.Theta=0;
                    end
                    EnvironmentCfg.Arrays{end+1}.Cfg=SensorCfg;
                    EnvironmentCfg.Arrays{end}.Sensors=...
                        SPF_AddElements({},SensorCfg);
                    %                 EnvironmentCfg.SensorsCfg=...
                    %                     SPF_AddElements(EnvironmentCfg.SensorsCfg,SensorCfg);
                    %% SensorCfg3
                    %% ...
                end
            end
            SimCfg.Environments{end+1}=EnvironmentCfg;
        end
        %% Scenarios
        SimCfg.Scenarios={};
        if true
            %% Scenario1
            ScenarioCfg=[];
            if true
                %% General
                if true
                    ScenarioCfg.nSnapshots=100;
                    %% Physiscs
                    ScenarioCfg.fCarrier=1e9;
                    ScenarioCfg.PropagationSpeed=3e8;
                    %% Statistics
                    ScenarioCfg.Noise.Sigma=0.01;
                    %% Algorithm
                    ScenarioCfg.DOA.res=0.5;
                end
                %% Sources
                ScenarioCfg.Sources.SignalType='CW';
                ScenarioCfg.Sources.SignalType='QAM';
            end
            SimCfg.Scenarios{end+1}=ScenarioCfg;
        end
    end
else
    SimCfg=PRESET_SimCfg;
end
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
