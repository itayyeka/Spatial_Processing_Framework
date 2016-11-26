function [SensorsCfg] = SPF_AssignFiltersToSensors(SensorsCfg,FiltersCfg)
for SensorID=1:numel(SensorsCfg)
    if isempty(FiltersCfg)
        SensorsCfg{SensorID}.Filter.Num=1;
        SensorsCfg{SensorID}.Filter.Den=1;
    end
end
end

