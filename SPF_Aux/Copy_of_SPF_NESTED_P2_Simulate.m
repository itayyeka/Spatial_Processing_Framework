function [Results] = SPF_NESTED_P2_Simulate(EnvironmentCfg,ScenarioCfg)
EnvironmentCfg.SourcesCfg=...
    SPF_AssignSignalsToSources(...
    EnvironmentCfg.SourcesCfg,...
    ScenarioCfg ...
    );
[InputSig_CellArr_Noised] = SPF_GenInput(EnvironmentCfg,ScenarioCfg);
%% Implementation of the paper "NESTED ARRAYS IN TWO DIMENSIONS, PARTII"
if true
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
        ArrCfg=EnvironmentCfg.Arrays{1}.Cfg;
        Nd=ArrCfg.Nd;
        Ns=ArrCfg.Ns;
        Nd_Tilda=ArrCfg.Nd_Tilda;
        N1_s=ArrCfg.N1_s;
        N2_s=ArrCfg.N2_s;
        lambda1=ArrCfg.lambda1;
        lambda2=ArrCfg.lambda2;
        DenseArrayGenerator=ArrCfg.DenseArrayGenerator;
        SparseArrayGenerator=ArrCfg.SparseArrayGenerator;
        %% build k1_VEC and k2_VEC
        k1_Min=-N1_s*lambda1-(lambda1-1)/2;
        k1_Max=lambda1*N1_s+(lambda1-1)/2;
        k2_Min=-((N2_s-1)*lambda2+lambda2-1);
        k2_Max=lambda2*(N2_s-1)+lambda2-1;
        k1_VEC=k1_Min:k1_Max;
        k2_VEC=k2_Min:k2_Max;
        Rxx_RowIdVec=[];
        ni_SYM=sym('ni_%d',[2 1]);
        nk_SYM=sym('nk_%d',[2 1]);
        assume(ni_SYM,'real');
        assume(nk_SYM,'real');
        IdMAT=[];
        i_k1k2_VEC=[];
        k_k1k2_VEC=[];
        for k1=k1_VEC
            for k2=k2_VEC
                %% Build the equation
                eqn_RHS=Ns*ni_SYM-Nd*nk_SYM;
                eqn_LHS=k1*Nd_Tilda(:,1)+k2*Nd_Tilda(:,2);
                eqn=(eqn_LHS==eqn_RHS);
                [eqn_SOL]=solve(eqn);
                i_k1k2_VEC=[i_k1k2_VEC i_k1k2];
                k_k1k2_VEC=[k_k1k2_VEC k_k1k2];
                IdMAT=[IdMAT [eqn_LHS ; k1; k2; i_k1k2; k_k1k2]];
                AAA=1;
            end
        end
        i_k1k2_VEC=unique(i_k1k2_VEC);
        k_k1k2_VEC=unique(k_k1k2_VEC);
        eval(IdMAT)
    end
end
end