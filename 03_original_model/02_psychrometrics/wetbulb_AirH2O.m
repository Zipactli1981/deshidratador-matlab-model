function Tw=wetbulb_AirH2O(T,w,P)

syms Twb
GI=T/2;
RH=relhum_AirH2O(T,w,P);
A=16.3872; B=3885.7; C=230.17;
Tw=vpasolve(exp(A-B/(Twb+C))*760/101.3-exp(A-B/(T+C))*760/101.3*RH-0.55*(T-Twb),Twb,GI);
