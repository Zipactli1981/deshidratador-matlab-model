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

clc
clear
close all

global A_eff_prod A_eff_shelf hconv_air_prod hconv_air_shelf Fm_dry_air omega_in h_air_in ...
    m_air Cp_air Cp_d Cp_w m_shelf Cp_shelf A B C P_amb HR_in v_in W0 m_i md cinetica on_prod on_shelf
%% Condiciones ambiente
P_amb=113.6; %Presión ambiente [kPa]
v_in=0.5; % Velocidad de entrada de aire [m/s]
%% Características de aire
Fm_dry_air=0.424; % Flujo másico de aire seco [kg/s]
omega_in=0.01074; % Humedad específica de entrada [-]
T_air_in=60; % Temperatura de entrada del aire [kJ/kg]
Cp_air=0.98; % Calor específico del aire [kJ/kg°C]
m_air=10; % Masa de aire al interior del túnel [kg]
HR_in=relhum_AirH2O(T_air_in,omega_in,P_amb);
h_air_in=enthalpy_AirH2O(T_air_in,P_amb,HR_in); % Entalpía de entrada del aire [kJ/kg]

%% Características de producto
W0=200; % Peso inicial del producto [kg]
m_i=0.73; % Contenido inicial de humedad del producto en base húmeda [kg agua/kg aire]
cinetica="Chile"; % Cambio de cinéticas
Cp_d=1.85; % Calor específico del producto seco [kJ/kg°C]
Cp_w=4.187; %Calor específico de agua [kJ/kg°C]
A_eff_prod=11.3; % Área efectiva del producto [m^2]
A=16.3872; B=3885.7; C=230.17; % constantes de Antoine agua
hconv_air_prod=0.015; %Coef. conv.  aire -producto [kW/m^2°C]
on_prod=true;
%% Características gabinete
A_eff_shelf=20.56; %Área efectiva del producto y del gabinete [m^2]
Cp_shelf=0.468; %Calor específico de los gabinetes[kJ/kg°C]
m_shelf=550; %masa de los gabinetes de acero [kg]
hconv_air_shelf=0.05; % Coef. conv. aire gabinete []
on_shelf=true;

horas=30; %Tiempo de experimentación
tiempo = 0:100:3600*horas;
M=zeros(size(tiempo));
k=(0.003484-0.000222*T_air_in+0.00000366*T_air_in^2-0.007085*HR_in+0.00572*HR_in^2+0.002738*v_in-0.001235*v_in^2)/60;
Me=(-340.573+5.787472*T_air_in-193.212*HR_in+238.7285*HR_in^2-22.3649*v_in+32.9541*v_in^2);
M0_Me=(584.8448-5.40847*T_air_in+239.8359*HR_in-260.357*HR_in^2+29.1755*v_in-48.838*v_in^2);
M=Me + (M0_Me) * exp(-k * tiempo);

R=find(M<M(1)*0.05);
szR=size(R,2);

if R>0
for i=1:szR
    M(R(i))=M(1)*0.05;
end
end
figure (1)

plot (tiempo/3600,M)
%% Llamado de EDO
if R>0
    tiempo = 0:100:tiempo(R(1));
end
T_in=temperature_AirH2O(h_air_in,P_amb,omega_in); %Cálculo de la temperatura de aire
x0=[T_in 25 25]; % Valores iniciales
[t,x]=ode23tb(@fun_modelo2,tiempo,x0); %Resolución de ecuaciones diferenciales
if R>0
    szM=size(M,2);
    Ta=zeros(szM,1);
    Tp=zeros(szM,1);
    Ts=zeros(szM,1);
    for i=1:R(1)
        Ta(i)=x(i,1);Tp(i)=x(i,2);Ts(i)=x(i,3);
    end
    val=R(1);
    for i=R(1):R(szR)
        Ta(i)=Ta(i-1);
        Tp(i)=Tp(i-1);
        Ts(i)=Ts(i-1);
    end
else
    Ta=x(:,1);Tp=x(:,2);Ts=x(:,3);
end
%% Elaboración de figuras

figure(2)
tiempo = 0:100:3600*horas;
plot(tiempo/3600,Ta,tiempo/3600,Tp,tiempo/3600,Ts);title('Comportamiento de la temperatura aire-producto-gabinete');
xlabel('Tiempo [h]');ylabel('Temperatura [°C]')
yline(T_in,'r--');
legend('T_{aire}','T_{producto}','T_{gabinete}',"Location","best")
grid on

function fx=fun_modelo2(tiempo,x)

global A_eff_prod A_eff_shelf hconv_air_prod hconv_air_shelf Fm_dry_air omega_in h_air_in ...
    m_air Cp_air Cp_d Cp_w m_shelf Cp_shelf HR_in v_in W0 m_i md cinetica on_prod on_shelf

%% Sistema de ecuaciones algeráicas "Balances de masa y energía"

fx=ones(3,1);
Ta=x(1);Tp=x(2);Ts=x(3);

Mi = m_i / (1-m_i); % "Contenido inicial de humedad del producto en base seca"
mwi = W0 * m_i; % "Contenido inicial de masa de agua"
md = mwi / Mi; % "masa de producto seco"
m_f = 0.25; % "Contenido final de humedad en base húmeda"
Me = m_f / (1-m_f); % "Contenido final de humedad en base seca"
mwe = Me * md; % "Masa final de agua"

%% Calor aire - producto

Qp_air_prod = hconv_air_prod * A_eff_prod * (Ta-Tp)*on_prod;

%% Calor aire - gabinete

Qp_air_shelf = hconv_air_shelf * A_eff_shelf * (Ta-Ts)*on_shelf;

%% Calor total

Q_TOT = Qp_air_prod + Qp_air_shelf;

%% Constante cinética polinomial

if strcmp(cinetica,"Chile")
    k=(0.003484-0.000222*Ta+0.00000366*Ta^2-0.007085*HR_in+0.00572*HR_in^2+0.002738*v_in-0.001235*v_in^2)/60;
    Me=(-340.573+5.787472*Ta-193.212*HR_in+238.7285*HR_in^2-22.3649*v_in+32.9541*v_in^2)/60;
    M0_Me=(584.8448-5.40847*Ta+239.8359*HR_in-260.357*HR_in^2+29.1755*v_in-48.838*v_in^2)/60;
end

%%Flujo de masa de agua (desde el producto)

M=Me + (M0_Me) * exp(-k * tiempo);

if M<=(Me + (M0_Me) * exp(-k * 0))*0.15;
    M=(Me + (M0_Me) * exp(-k * 0))*0.15;
end

Fm_w = abs(-k * ( M - Me));

%% Entalpía de cambio de fase
h_w = 2500 + Cp_w * Ta;

%% Humedad específica(salida)
omega_out = (Fm_dry_air*omega_in + Fm_w)/Fm_dry_air;

%% Entalpía de salida
h_out = Cp_air * Ta + omega_out * h_w;

%% Masa de agua (en el producto)
mw = (Me + (M0_Me) * exp(-k * tiempo))*md;

%% Sistema de ecuaciones diferenciales Balance de energía (Aire)

fx(1)=(Fm_dry_air * h_air_in + Fm_w * h_w - (Fm_dry_air * h_out + (Q_TOT)))/(m_air * Cp_air); % dT_air/dt=(mp_dry_air*omega_in*h_air_in+Fm_w*h_w-(Fm_dry_air*omega_out*h_out+Qp_TOT))/(m_air*Cp_air);

%% Balance de energía (Producto)

fx(2)=(Qp_air_prod-Fm_w*h_w)/(md*Cp_d+mw*Cp_w)*on_prod; % dT_prod/dt=(Qp_air_prod-Fm_w*h_w)/(md*Cp_d+mw*Cp_w);

%% Balance de Energía (Gabinete)

fx(3)=Qp_air_shelf/(m_shelf*Cp_shelf)*on_shelf; % dT_shelf/dt=Qp_air_shelf/(m_shelf*Cp_shelf);


end


