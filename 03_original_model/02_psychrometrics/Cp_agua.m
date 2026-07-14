function Cp=Cp_agua(T) % Ecuación de gas ideal para vapor de agua
a1=32.24;b1=0.1923e-2;c1=1.055e-5;d1=-3.595e-9;
Cpagua_m=a1+b1*(T+273.15)+c1*(T+273.15)^2+d1*(T+273.15)^3;
M=18.015;
Cp=Cpagua_m/M;