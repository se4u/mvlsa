clc, clear, close all
d=3; n=1000; k=3; 
p=3; q=3; r=3; 
regX=1e-08; regY=1e-08; regZ=1e-08; 
A=randn(d,n);
Wxt=orth(randn(d,p));
Wyt=orth(randn(d,q));
Wzt=orth(randn(d,r));
X=Wxt'*A;
Y=Wyt'*A;
Z=Wzt'*A;
[Wx,Wy,Wz,r]=gcca(X,Y,Z,regX,regY,regZ,k,n);
fprintf('Errors in the original basis: %g, %g, %g\n',...
    norm(X-Y),norm(Y-Z),norm(X-Z));
fprintf('Errors in the new(GCCA) basis: %g, %g, %g\n',...
    norm(Wx'*X-Wy'*Y), norm(Wx'*X-Wz'*Z), norm(Wy'*Y-Wz'*Z));
