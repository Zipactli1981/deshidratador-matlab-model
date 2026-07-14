function omega=humrat_AirH2O(T,P,HR)
Psat=Antoine_agua(T);
Pv=Psat*HR;
Pa=P-Pv;
omega=0.622*Pv/Pa;
