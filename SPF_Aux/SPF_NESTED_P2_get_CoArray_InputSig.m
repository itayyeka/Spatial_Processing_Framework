function [coArray_POS_VEC,z1] = SPF_NESTED_P2_get_CoArray_InputSig(EnvironmentCfg,ScenarioCfg,InputSig_CellArr_Noised)
%% Generate the virtual array input signal
%{
    After creating the input signals to the physical array (InputSig_CellArr_Noised)
    we actually ahve the x[k] from eqn8 in the paper
%}
%% fetch x
nSensors=numel(InputSig_CellArr_Noised);
nSnapshots=length(InputSig_CellArr_Noised{1});
x_MAT=cell2mat(reshape(InputSig_CellArr_Noised,[],1));
x_CELL=mat2cell(x_MAT,nSensors,ones(1,nSnapshots));
%% Rxx=E{x*x^H}
Rxx_t_CELL=cellfun( ...
    @(x) x(:)*conj(transpose(x(:))),...
    x_CELL,'UniformOutput',false);
Rxx_t=cell2mat(reshape(Rxx_t_CELL,1,1,[]));
Rxx=mean(Rxx_t,3);
%% z=vec(Rxx)
z=Rxx(:);
%% b indices
if true
    %% fetch array configuration
    PhysicalArrCfg=EnvironmentCfg.Arrays{1}.Cfg;
    [coArray_POS_VEC] = SPF_NESTED_P2_ResolveVirtualArrayPostions(PhysicalArrCfg);    
    %% build the co-array from the b_k1 b_k2 lines
    diff_POS_VEC=[];
    ArrayLocations=PhysicalArrCfg.ArrayLocations;
    for First_SensorID=1:size(ArrayLocations,2)
        for Second_SensorID=1:size(ArrayLocations,2)
            First_Sensor_POS=ArrayLocations(:,First_SensorID);
            Second_Sensor_POS=ArrayLocations(:,Second_SensorID);
            diff_SinglePOS=...
                First_Sensor_POS ...
                - ...
                Second_Sensor_POS;
            diff_SinglePOS=[diff_SinglePOS ; 0]; % The z coordinate is always zeros in our simulation
            diff_POS_VEC=[diff_POS_VEC diff_SinglePOS];
        end
    end
    %% Match positions and indices
    Rxx_SensorToLine_MAP=[];
    for coArray_SensorID=1:size(coArray_POS_VEC,2)
        coArray_SensorPOS=coArray_POS_VEC(:,coArray_SensorID);
        ExistanceVEC=...
            sum(abs(...
            diff_POS_VEC ...
            - ...
            repmat(coArray_SensorPOS,1,size(diff_POS_VEC,2)) ...
            ));
        SensorMatchingLineID_InRxx=find(~ExistanceVEC,1);
        Rxx_SensorToLine_MAP=[Rxx_SensorToLine_MAP SensorMatchingLineID_InRxx];
    end
    assert(length(Rxx_SensorToLine_MAP)==size(coArray_POS_VEC,2),'Every coArray sensor must have a matching line in Rxx');
end
%% z1 = A_diff*p + (sigma^2)*e'
z1=reshape(z(Rxx_SensorToLine_MAP),[],1);
end

