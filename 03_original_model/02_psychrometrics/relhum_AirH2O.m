function RH=relhum_AirH2O(T,w,P);

Psat=Antoine_agua(T);

RH=w*P/((0.622+w)*Psat);