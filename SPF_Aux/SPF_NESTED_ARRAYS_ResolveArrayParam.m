function [N1_s,N2_s,lambda1,lambda2,K1,K2,DOF] = ...
    SPF_NESTED_ARRAYS_ResolveArrayParam(K)
KPlus1Mod4=mod(K+1,4);
p=floor((K+1)/4);
DK=0.5*(K+1)^2 - 0.5*(K+1);
N1_s=0;
lambda1=1;
if mod(K,2)==1
    N2_s=0.5*(K+1);
    lambda2=N2_s;
elseif mod(K,2)==0
    N2_s=0.5*(K+2);
    lambda2=K/2;
end
switch KPlus1Mod4
    case 0        
        K1=2*p-2; 
        K2=2*p+1;
        DOF=DK-1;
    case 1        
        K1=2*p; 
        K2=2*p;
        DOF=DK-1;
    case 2        
        K1=2*p; 
        K2=2*p+1;
        DOF=DK;
    case 3        
        K1=2*p; 
        K2=2*p+2;
        DOF=DK;
end
end