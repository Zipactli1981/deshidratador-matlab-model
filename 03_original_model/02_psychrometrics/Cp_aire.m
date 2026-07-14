function Cp=Cp_aire(T)
a2=28.11;b2=0.1967e-2;c2=0.4802e-5;d2=-1.966e-9;
Cpaire_m=a2+b2*(T+273.15)+c2*(T+273.15)^2+d2*(T+273.15)^3;
Maire=28.97;
Cp=Cpaire_m/Maire;