function [...
    newElements,...
    Nd_Tilda,...
    U1,...
    Nd,...
    Ns,...
    P,...
    N1_s,...
    N2_s,...
    lambda1,...
    lambda2,...
    DOF,...
    DenseArrayGenerator,...
    SparseArrayGenerator, ...
    Sparse_mVEC,...
    Sparse_nVEC,...
    Dense_mVEC,...
    Dense_nVEC, ...
    K1,...
    K2, ...
    ArrayPositions ...
    ] = SPF_NESTED_ARRAYS_GenerateSenors(ElementCfg)
K=ElementCfg.ShapeCfg.nElements;
%% Fetch K-related parameters
[...
    N1_s,...
    N2_s,...
    lambda1,...
    lambda2,...
    K1,...
    K2,...
    DOF, ...
    skewDELTA ...
    ] = ...
    SPF_NESTED_ARRAYS_ResolveArrayParam(...
    K ...
    );
%% Resolve the wanted grid
ULAs_AngleVEC_DEG=ElementCfg.ShapeCfg.ULAs_AngleVEC_DEG;
ULAs_AngleVEC_RAD=f_convert_deg_to_rad(ULAs_AngleVEC_DEG);
DenseElementsSpacing=ElementCfg.ShapeCfg.DenseElementsSpacing;
SparseElementsSpacing=ElementCfg.ShapeCfg.SparseElementsSpacing;
ULAs_Coordinates_COMPLEX=...
    exp(1i*ULAs_AngleVEC_RAD);
VectorsMAT=...
    [ ...
    real(ULAs_Coordinates_COMPLEX)...
    ; ...
    imag(ULAs_Coordinates_COMPLEX)...
    ] ...
    * ...
    [DenseElementsSpacing 0 ; 0 SparseElementsSpacing];
SparseVector=VectorsMAT(:,2);
DenseVector=VectorsMAT(:,1);
%% Choose "TOTALLY-UNIMODULAR" U1,U2
%{
U1 U2 should be "TOTALLY unimodular"!!! this is not mentioned in the article.
"totally unimodular" means that the entries are ONLY -1,0,+1
Any other type of unimodular matrices causes the solve to fail.
%}
U1=[+1 +1 ; -1  0]; % Chose arbitrary unimodular matrix
U2=[+1  0 ; +1 +1]; % Chose arbitrary unimodular matrix
%% Create P
P=U1*diag([lambda1 lambda2])*U2;
%% SYMBOLIC solving of Ns Nd Nd_Tilda
if true
    %% Create SYMBOLICS
    Nd_SYM=sym('Nd_%d%d',[2 2]);
    Ns_SYM=sym('Ns_%d%d',[2 2]);
    NsInvU2_SYM=Ns_SYM/U2; % b/A == b*Inv(A)
    NdU1_SYM=Nd_SYM*U1;
    %% EQN1
    %{
    The locations of the physical elements on the sparse grid are according to:
    Ns*inv(U2)*[m ; n]
    where
    -N1_s   <=  m   <= N1_s
    0       <=  n   <= N2_s-1
    %}
    if N1_s==0
        eqn1=(NsInvU2_SYM(:,2)==SparseVector);
        eqn1_fsolve=NsInvU2_SYM(:,2)-SparseVector;
    elseif N2_s==1
        eqn1=(NsInvU2_SYM(:,1)==SparseVector);
        eqn1_fsolve=NsInvU2_SYM(:,1)-SparseVector;
    else
        assert('something is wrong');
    end
    %% EQN2
    %{
    The locations of the physical elements on the dense grid are according to:
    CONFIGURATION II: (the one we implement)
    Nd*U1*[m ; n]
    where
    -(lambda1-1)/2   <=  m   <= +(lambda1-1)/2
    -lambda2+1       <=  n   <= 0
    %}
    if lambda1==1
        eqn2=(NdU1_SYM==[SparseVector -DenseVector]);
        eqn2_fsolve=NdU1_SYM-[SparseVector -DenseVector];
    elseif lambda2==1
        eqn2=(NdU1_SYM==[DenseVector SparseVector]);
        eqn2_fsolve=NdU1_SYM-[DenseVector SparseVector];
    else
        assert('something is wrong')
    end
    %% EQN3
    %{
    The basic relation between Ns and Ns
    Ns=P*Nd
    %}
    eqn3=(Ns_SYM==P*Nd_SYM);
    eqn3_fsolve=Ns_SYM-P*Nd_SYM;
    %% SOLVE
    eqns_SOL=solve([eqn1,eqn2,eqn3]);
    Nd=eval(subs(Nd_SYM,eqns_SOL));
    Ns=eval(subs(Ns_SYM,eqns_SOL));
    Nd_Tilda=subs(NdU1_SYM,eqns_SOL);
    if isempty(eqns_SOL.Nd_11)
        disp('No exact solution - executed fmincon');
        eqn_VEC=[eqn1_fsolve(:) ; eqn2_fsolve(:) ; eqn3_fsolve(:)];
        eqn_SymVars=symvar(eqn_VEC);
        eqn_SymVars=eqn_SymVars(:);
        coef_MAT=[];
        for eqnID=1:size(eqn_VEC,1)
            CurEqn=eqn_VEC(eqnID);
            CurEqn_SymVar=symvar(CurEqn);
            [coef_TEMP]=coeffs(eqn_VEC(eqnID),CurEqn_SymVar);
            SymIDs=find(ismember(eqn_SymVars,CurEqn_SymVar));
            Line=zeros(1,length(eqn_SymVars));
            Line(SymIDs(:))=coef_TEMP(1:length(CurEqn_SymVar));
            coef_MAT=[coef_MAT ; Line];
        end
        TargetFunc=@(X) sum((coef_MAT*X).^2);
        fmincon_CFG=optimoptions(@fmincon);
        fmincon_CFG.FunctionTolerance=1e-10;
        fmincon_CFG.OptimalityTolerance=1e-10;
        fmincon_CFG.ConstraintTolerance=1e-10;
        fmincon_CFG.StepTolerance=1e-10;
        fVAL=1;
        while fVAL>1e-3
            [eqns_SOL_fsolve,fVAL]=...
                fmincon( ...
                TargetFunc,...fun
                rand(length(eqn_SymVars),1),...x0
                coef_MAT,...A
                zeros(size(coef_MAT,1),1),...b
                [],...Aeq
                [],...beq
                0.1*DenseElementsSpacing*ones(length(eqn_SymVars),1),...lb
                1000*ones(length(eqn_SymVars),1),...ub
                [],...noncolon
                fmincon_CFG ...opt
                );
        end
        Nd=eval(subs(Nd_SYM,eqn_SymVars,eqns_SOL_fsolve));
        Ns=eval(subs(Ns_SYM,eqn_SymVars,eqns_SOL_fsolve));
        Nd_Tilda=subs(NdU1_SYM,eqn_SymVars,eqns_SOL_fsolve);
    end
end
%% ASSIGN SOLUTIONS
ArrayPositions=[];
%{
ArrayPositions will hold the locations of the ARRAY as follows:
[Sparse_grid_locations Dense_grid_locations]
%}
%% Sparse array elements
%{
Ns*Inv(U2)*[m ; n]
-N1_s   <= m <= N1_s
0       <= n <= N2_s-1
%}
ArrayPositions=[];
SparseArrayGenerator=Ns/U2; % b/A == b*Inv(A)
m_MIN=-N1_s;
m_MAX=N1_s;
n_MIN=0;
n_MAX=N2_s-1;
mVEC=m_MIN:m_MAX;
nVEC=n_MIN:n_MAX;
for m=mVEC
    for n=nVEC
        POS=SparseArrayGenerator*[m ; n];
        if ~isequal(POS,zeros(size(POS)))
            %{
            Here we create the n1d_Tilda which excludes the 0 element
            %}
            ArrayPositions=[ArrayPositions POS];
        end
    end
end
Sparse_mVEC=mVEC;
Sparse_nVEC=nVEC;
%% Dense array elemetns
%{
According to configuration II:
Nd*U1*[m ; n];
%}
DenseArrayGenerator=Nd*U1;
m_MIN=-(lambda1-1)/2;
m_MAX=(lambda1-1)/2;
n_MIN=-lambda2+1;
n_MAX=0;
mVEC=m_MIN:m_MAX;
nVEC=n_MIN:n_MAX;
for m=mVEC
    for n=nVEC
        POS=DenseArrayGenerator*[m ; n];
        %{
        Here we create the n2d_Tilda which includes the 0 element
        %}
        ArrayPositions=[ArrayPositions POS];
    end
end
Dense_mVEC=mVEC;
Dense_nVEC=nVEC;
newElements_MAT=[ArrayPositions;zeros(1,size(ArrayPositions,2))];
newElements=mat2cell(newElements_MAT,3,ones(1,size(ArrayPositions,2)));
end