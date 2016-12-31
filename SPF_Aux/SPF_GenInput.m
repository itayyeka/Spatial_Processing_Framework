function [InputSig_CellArr_Noised] = SPF_GenInput(EnvironmentCfg,ScenarioCfg)
f_SumSources=@(Sensor,Sources,ScnCfg) ...
    reshape(... 5. reshape the output to be a row vector. Each element is the input to the relevant sensor
    sum(...4. sum the columns of the matrix
    cell2mat(... 3. create matrix to allow summation
    reshape(... 2. reshape the cell array as column of cells with one row each (each element in the row is the contribution of a source to the relevant sensor)
    cellfun( ...
    @(Source) f_SenseSource(Sensor,Source,ScnCfg), ... 1. get input from each source to the relevant sensor
    Sources, ...
    'UniformOutput',false), ...
    [],1) ...
    ),1 ... 
    ), ...
    1,[]);
InputSig_CellArr=cellfun(...
    @(Sensor) f_SumSources(Sensor,EnvironmentCfg.SourcesCfg,ScenarioCfg),...
    EnvironmentCfg.SensorsCfg, ...
    'UniformOutput',false);
InputSig_CellArr_Noised=cellfun(...
    @(Signal) Signal+ScenarioCfg.Noise.Sigma*randn(size(Signal)), ...
    InputSig_CellArr, ...
    'UniformOutput',false);
if false
    %% DEBUG
    figure;
    subplot(2,1,1)
    plot(real(cell2mat(InputSig_CellArr)));
    subplot(2,1,2)
    plot(real(cell2mat(InputSig_CellArr_Noised)));
end
end
function Signal=f_SenseSource(Sensor,Source,ScnCfg)
%{
Without loss of generality, in case of incoherent sources, the simulation
behaves like all signals start at the same time, although each signal
arrives from different range. A simular result will be achieved from
treating each signal as periodic and infinite. The statistics will stay the
same due to the basic assumption of Argodic (constant statistics) signals.

Simulation is executed in base-band, therefore, the signal in each sensor
is only the complex envelope of the RF signal.

It is assumed that all sources are transmitting in the same sample rate and
that the receiver also samples the complex envelope at the same rate.

The exponent in the final expression is there to generate the phase
difference between the sensors.
exp(jwt)=exp(j*2pi*f*t)=exp(j*k*c*t)
t = Range/c
=> =exp(j*k*Range)
%}
c=ScnCfg.PropagationSpeed;
fCarrier=ScnCfg.fCarrier;
Lambda=c/fCarrier;
k=2*pi/Lambda;
Sensor_POS=Sensor.Position(:);
Source_POS=Source.Position(:);
r_VEC=Sensor_POS-Source_POS;
Range=sqrt(sum(r_VEC.^2));
PhaseDiff=k*Range;
Wrap_PhaseDiff=mod(PhaseDiff,2*pi)/pi;
Signal_PreProcess=reshape(...
    Source.Signal(1:ScnCfg.nSnapshots)*exp(-1i*PhaseDiff)/Range ...
    ,1,[]);
Signal=filter(...
    Sensor.Filter.Den,...
    Sensor.Filter.Num,...
    Signal_PreProcess ...
    );
end