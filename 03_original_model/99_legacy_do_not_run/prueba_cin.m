clc
clear
close all

Ta=45;
HR_in=0.2;
v_in=0.5;
i=1;

%for Ta=40:65
for t=0:1600    
k(i)=0.003484-0.000222*Ta+0.00000366*Ta^2-0.007085*HR_in+0.00572*HR_in^2+0.002738*v_in-0.001235*v_in^2;
Me(i)=-340.573+5.787472*Ta-193.212*HR_in+238.7285*HR_in^2-22.3649*v_in+32.9541*v_in^2;
M0_Me(i)=584.8448-5.40847*Ta+239.8359*HR_in-260.357*HR_in^2+29.1755*v_in-48.838*v_in^2;
M(i)=Me(i)+(M0_Me(i))*exp(-k(i)*t);
i=i+1;

end
t=0:1600;
%Ta=40:65;
%plot(Ta,k)
plot(t,M);title('Behavior of M');xlabel('Time (min)');ylabel('Moisture content(db)')