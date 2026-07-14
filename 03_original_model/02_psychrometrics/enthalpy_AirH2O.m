function h=enthalpy_AirH2O(T,P,HR)

Cp=Cp_agua(T);

hg=2500.9+Cp*T; 

omega=humrat_AirH2O(T,P,HR);

Cpaire=Cp_aire(T);

h=Cpaire*T+omega*hg;
