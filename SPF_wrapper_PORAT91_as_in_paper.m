clearvars;
%{
Here the SimCfg is built to accuratly reproduce the smulations in PRAT91
paper.
%}
SEED=100;
global SPF_FLAGS;
SPF_FLAGS=[];
SPF_FLAGS.VERBOSE=1;
[FuncPath,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(FuncPath,'SPF_Aux')));
%% SimCfg
rng('default');
rng(SEED);
if true
    %% Algorithms
    SimCfg.Algorithms={...
        'PORAT91_A' ...
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
            if true
                %% SourceCfg1
                SourceCfg=[];
                if true
                    %% Source parameters
                    SourceCfg.Distance=100;
                    SourceCfg.Phi=f_convert_deg_to_rad(20);
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
                EnvironmentCfg.SourcesCfg=...
                    SPF_AddElements(EnvironmentCfg.SourcesCfg,SourceCfg);
                %% SourceCfg3
                SourceCfg=[];
                if true
                    %% Source parameters
                    SourceCfg.Distance=100;
                    SourceCfg.Phi=f_convert_deg_to_rad(60);
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
                    ElementSpacing=0.1;
                    SensorCfg.Distance=0;
                    SensorCfg.Phi=0;
                    SensorCfg.Theta=0;
                    SensorCfg.Shape='ula';
                    SensorCfg.ShapeCfg.nElements=5;
                    SensorCfg.ShapeCfg.Size=...
                        (SensorCfg.ShapeCfg.nElements-1)*ElementSpacing;
                    SensorCfg.ShapeCfg.Orientation.Phi=0;
                    SensorCfg.ShapeCfg.Orientation.Theta=0;
                end
                EnvironmentCfg.SensorsCfg=...
                    SPF_AddElements(EnvironmentCfg.SensorsCfg,SensorCfg);
                %% SensorCfg2
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
                ScenarioCfg.Noise.SNR=inf;
                %% Algorithm
                ScenarioCfg.DOA.res=0.5;
            end
            %% Sources
            ScenarioCfg.Sources.SignalType='QAM';
%             ScenarioCfg.Sources.SignalType='CW';
        end
        SimCfg.Scenarios{end+1}=ScenarioCfg;
    end
end
SPF_Main(SimCfg);