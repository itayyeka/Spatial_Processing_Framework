function [N1_s,N2_s,lambda1,lambda2,K1,K2,DOF,skewDELTA] = ...
    SPF_NESTED_ARRAYS_ResolveArrayParam(K)
KPlus1Mod4=mod(K+1,4);
p=floor((K+1)/4);
DK=0.5*(K+1)^2 - 0.5*(K+1);
switch KPlus1Mod4
    case 0
        N1_s        = p-1;
        N2_s        = 1;
        lambda1     = 1;
        lambda2     = 2*p+1;
        K1          = 2*p-2;
        K2          = 2*p+1;
        DOF         = DK-1;
        skewDELTA   = 2;
    case 1
        N1_s        = 0;
        N2_s        = 2*p;
        lambda1     = 2*p+1;
        lambda2     = 1;
        K1          = 2*p;
        K2          = 2*p;
        DOF         = DK-1;
        skewDELTA   = -1;
    case 2
        N1_s        = p;
        N2_s        = 1;
        lambda1     = 1;
        lambda2     = 2*p+1;
        K1          = 2*p;
        K2          = 2*p+1;
        DOF         = DK;
        skewDELTA   = 0;
    case 3
        N1_s        = p;
        N2_s        = 1;
        lambda1     = 1;
        lambda2     = 2*p+2;
        K1          = 2*p;
        K2          = 2*p+2;
        DOF         = DK;
        skewDELTA   = 1;
end
end