%   __  __           _      _         ____                              
%  |  \/  | ___   __| | ___| | ___   |___ \                             
%  | |\/| |/ _ \ / _` |/ _ \ |/ _ \    __) |                            
%  | |  | | (_) | (_| |  __/ | (_) |  / __/                             
%  |_|  |_|\___/ \__,_|\___|_|\___/  |_____|                            
%       _           _     _     _           _             _   __        
%    __| | ___  ___| |__ (_) __| |_ __ __ _| |_ __ _  ___(_) /_/  _ __  
%   / _` |/ _ \/ __| '_ \| |/ _` | '__/ _` | __/ _` |/ __| |/ _ \| '_ \ 
%  | (_| |  __/\__ \ | | | | (_| | | | (_| | || (_| | (__| | (_) | | | |
%   \__,_|\___||___/_| |_|_|\__,_|_|  \__,_|\__\__,_|\___|_|\___/|_| |_|
% 
clc
clear
close all

global A_eff_prod A_eff_shelf hconv_air_prod hconv_air_shelf Fm_dry_air omega_in h_air_in...
    m_air Cp_air Cp_d Cp_w m_shelf Cp_shelf A B C P_amb HR_in v_in W0 m_i md cinetica on_prod on_shelf

%Condiciones ambiente
P_amb=113.6; %Presión ambiente [kPa]
v_in=0.5; % Velocidad de entrada de aire [m/s]

%Características de aire
Fm_dry_air=0.424; % Flujo másico de aire seco [kg/s]
omega_in=0.01149; % Humedad específica de entrada [-]
T_air_in=65; % Temperatura de entrada del aire [kJ/kg]
Cp_air=0.98; % Calor específico del aire [kJ/kg°C]
m_air=5; % Masa de aire al interior del túnel [kg]
HR_in=relhum_AirH2O(T_air_in,omega_in,P_amb);
h_air_in=enthalpy_AirH2O(T_air_in,P_amb,HR_in); % Entalpía de entrada del aire [kJ/kg]

%Características de producto
W0=90; % Peso inicial del producto [kg]
m_i=0.8; % Contenido inicial de humedad del producto en base húmeda [kg agua/kg aire]
cinetica="Piña"; % Cambio de cinéticas Piña - Chile - Cero
Cp_d=1.85; % Calor específico del producto seco [kJ/kg°C]
Cp_w=4.187; %Calor específico de agua [kJ/kg°C]
A_eff_prod=4.41; % Área efectiva del producto [m^2]
A=16.3872; B=3885.7; C=230.17; % constantes de Antoine agua
hconv_air_prod=0.05; %Coef. conv.  aire -producto [kW/m^2°C]
on_prod=true;

%Características gabinete
A_eff_shelf=20.56; %Área efectiva del producto y del gabinete [m^2]
Cp_shelf=0.468; %Calor específico de los gabinetes[kJ/kg°C]
m_shelf=550; %masa de los gabinetes de acero [kg]
hconv_air_shelf=0.05; % Coef. conv. aire gabinete []
on_shelf=true;

%Llamado de EDO
horas=8; %Tiempo de experimentación
tiempo = 0:1:3600*horas;
T_in=temperature_AirH2O(h_air_in,P_amb,omega_in); %Cálculo de la temperatura de aire
x0=[4 T_in 25 25]; % Valores iniciales
[t,x]=ode23tb(@fun_modelo2,tiempo,x0); %Resolución de ecuaciones diferenciales

%Elaboración de figuras
figure(1)

plot(tiempo/3600,x(:,2:4));title('Comportamiento de la temperatura aire-producto-gabinete');
xlabel('Tiempo [h]');ylabel('Temperatura [°C]')
yline(T_in,'r--');
legend('T_{aire}','T_{producto}','T_{gabinete}',"Location","best")
grid on

figure(2)

plot(tiempo/3600,md*x(:,1));title('Comportamiento de la masa de agua');xlabel('Tiempo [h]');ylabel('Agua en producto [kg]')
grid on

function fx=fun_modelo2(tiempo,x)

global A_eff_prod A_eff_shelf hconv_air_prod hconv_air_shelf Fm_dry_air omega_in h_air_in...
    m_air Cp_air Cp_d Cp_w m_shelf Cp_shelf A B C P_amb HR_in v_in W0 m_i md cinetica on_prod on_shelf

%% Sistema de ecuaciones algeráicas 
%"Balances de masa y energía"
 
fx=ones(4,1);
M=x(1);Ta=x(2);Tp=x(3);Ts=x(4);

Mi = m_i / (1-m_i); % "Contenido inicial de humedad del producto en base seca"
mwi = W0 * m_i; % "Contenido inicial de masa de agua"
md = mwi / Mi; % "masa de producto seco"
m_f = 0.25; % "Contenido final de humedad en base húmeda"
Me = m_f / (1-m_f); % "Contenido final de humedad en base seca"
mwe = Me * md; % "Masa final de agua"
%Calor aire - producto


Qp_air_prod = hconv_air_prod * A_eff_prod * (Ta-Tp)*on_prod;
%Calor aire - gabinete


Qp_air_shelf = hconv_air_shelf * A_eff_shelf * (Ta-Ts)*on_shelf;
%Calor total


Q_TOT = Qp_air_prod + Qp_air_shelf;
%Constante cinética polinomial


if strcmp(cinetica,"Piña")
    k=(-2.97128+0.03536*v_in+0.07407*Ta)/3600;
end

if strcmp(cinetica,"Chile")
    k=(0.003484-0.000222*Ta+0.00000366*Ta^2-0.007085*HR_in+...
        0.00572*HR_in^2+0.002738*v_in-0.001235*v_in^2)/60;
end

if strcmp(cinetica,"Cero")
    k=0;
end


if k<0
    k=0;
end

%Flujo de masa de agua(desde el producto)

Fm_w = abs(-k * ( M - Me));

%Entalpía de cambio de fase

h_w = 2500 + Cp_w * Ta;

%Humedad específica (salida)

omega_out = (Fm_dry_air*omega_in + Fm_w)/Fm_dry_air;

%Entalpía de salida

h_out = Cp_air * Ta + omega_out * h_w;

%Masa de agua (en el producto)

mw = mwe + (mwi - mwe) * exp(-k * tiempo);

%% Sistema de ecuaciones diferenciales 
%Balance de masa(producto)

fx(1)=- k * ( M - Me);... ecuación (1)

%Balance de energía (Aire)

fx(2)=(Fm_dry_air * h_air_in + Fm_w * h_w - (Fm_dry_air * h_out + (Q_TOT)))/(m_air * Cp_air); %... ecuación (2)

%Balance de energía (Producto)

fx(3)=(Qp_air_prod-Fm_w*h_w)/(md*Cp_d+mw*Cp_w)*on_prod; %... ecuación (2)

%Balance de Energía(Gabinete)

fx(4)=Qp_air_shelf/(m_shelf*Cp_shelf)*on_shelf; ... ecuación (4)
    
end
