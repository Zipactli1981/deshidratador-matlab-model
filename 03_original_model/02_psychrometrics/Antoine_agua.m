function Psat=Antoine_agua(T)
A=16.3872; B=3885.7; C=230.17;
Psat=exp(A-B/(T+C));