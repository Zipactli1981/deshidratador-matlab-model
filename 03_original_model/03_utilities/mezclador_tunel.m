 function [vs]=mezclador_tunel(x,m_M8,w_M8,h_M8,P_amb,t)

%%Definición de variables

global Mi md Mf A_sec rec_max

syms x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18

A=16.3872; B=3885.7; C=230.17;%Constantes de Antoine

%% "Balance de materia y energía en mezclador 9"

fx(1)=x12*rec_max-x1; % "masa de recirculación de aire"
fx(2)=m_M8+x1-x2; % "masa de aire de entrada al túnel de secado"
fx(3)=(m_M8*w_M8+x1*x13)-x3*x2; % "humedad específica de la corriente de entrada"
fx(4)=x16-x4; % "entalpía de la corriente de recirculación"
fx(5)=(m_M8*h_M8+x1*x4)-x5*x2; %"entalpía de entrada al túnel de secado"
fx(6)=temperature_AirH2O(x5,P_amb,x3)-x6;
fx(7)=relhum_AirH2O(x6,x3,P_amb)-x7;

%% "Balance de materia y energía en el túnel de secado"

fx(8)=x2/(A_sec*density_AirH2O(x6,P_amb,x3))-x8; % "velocidad del flujo de aire"
fx(9)=0.003484-0.000222*x6+0.00000366*x6^2-0.007085*x7...
    +0.00572*x7^2+0.002738*x8-0.001235*x8^2-x9; % "constante de la velocidad de secado"
fx(10)=x9*md*(Mi-Mf)*exp(-x9*t/60)/60-x10; % "flujo de agua proveniente del producto deshidratado"
fx(18)=x2*x3-x18; % "masa de agua en la corriente de entrada al túnel"
fx(11)=x18+x10-x11; % "flujo de aire a la salida del túnel"
fx(12)=x2-x12; % "masa de aire seco en la corriente de salida del túnel"

fx(13)=x11-x13*x12; % "Humedad específica a la saida del túnel"

fx(14)=exp(A-B/(x14+C))*760/101.3-exp(A-B/(x6+C))...
    *760/101.3*x7-0.55*(x6-x14);%wetbulb_AirH2O(x6,x3,P_amb)-x14;
fx(15)=enthalpy_Water(x14)-x15; % "Cálculo de entalpía de agua"

fx(16)=(x2*x5+x10*x15)-x16*x12;
fx(17)=temperature_AirH2O(x16,P_amb,x13)-x17;

%% Resolución del sistema

v=[x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18];
A=jacobian(fx,v);

x1=x(1);x2=x(2);x3=x(3);x4=x(4);x5=x(5);
x6=x(6);x7=x(7);x8=x(8);x9=x(9);x10=x(10);
x11=x(11);x12=x(12);x13=x(13);x14=x(14);
x15=x(15);x16=x(16);x17=x(17);x18=x(18);

A=eval(A);
fx=eval(fx)';

B=A\fx;
vs=x-B;

%% Establecimiento de límites

for i=1:18
    if vs(i)<0
        vs(i)=0;
    end
end

% if vs(3)>1
%     vs(3)=1;
% end

if vs(7)>1
    vs(7)=1;
end

% if vs(13)>1
%     vs(13)=1;
% end

