function [coArray_POS_VEC] = SPF_NESTED_P2_ResolveVirtualArrayPostions(PhysicalArrCfg)
%% fetch array configuration
Nd=PhysicalArrCfg.Nd;
Ns=PhysicalArrCfg.Ns;
Nd_Tilda=PhysicalArrCfg.Nd_Tilda;
N1_s=PhysicalArrCfg.N1_s;
N2_s=PhysicalArrCfg.N2_s;
lambda1=PhysicalArrCfg.lambda1;
lambda2=PhysicalArrCfg.lambda2;
DenseArrayGenerator=PhysicalArrCfg.DenseArrayGenerator;
SparseArrayGenerator=PhysicalArrCfg.SparseArrayGenerator;
K1=PhysicalArrCfg.K1;
K2=PhysicalArrCfg.K2;
%% build all possible diffs
Sparse_mVEC=PhysicalArrCfg.Sparse_mVEC;
Sparse_mVEC=unique([Sparse_mVEC -Sparse_mVEC]);
Sparse_nVEC=PhysicalArrCfg.Sparse_nVEC;
Sparse_nVEC=unique([Sparse_nVEC -Sparse_nVEC]);
Dense_mVEC=PhysicalArrCfg.Dense_mVEC;
Dense_mVEC=unique([Dense_mVEC -Dense_mVEC]);
Dense_nVEC=PhysicalArrCfg.Dense_nVEC;
Dense_nVEC=unique([Dense_nVEC -Dense_nVEC]);
coArray_POS_VEC=[];
for ms=Sparse_mVEC
    for ns=Sparse_nVEC
        for md=Dense_mVEC
            for nd=Dense_nVEC
                CoArray_SinglePOS=...
                    SparseArrayGenerator*[ms ; ns] ...
                    - ...
                    DenseArrayGenerator*[md ; nd];
                CoArray_SinglePOS=[CoArray_SinglePOS ; 0]; % The z coordinate is always zeros in our simulation
                coArray_POS_VEC=[coArray_POS_VEC CoArray_SinglePOS];
            end
        end
    end
end
end

