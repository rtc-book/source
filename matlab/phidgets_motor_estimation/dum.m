clear; close all;

syms wn z 'positive'
syms x 'real'
l1 = -z*wn + wn*sqrt(z^2 - 1);
l2 = -z*wn - wn*sqrt(z^2 - 1);
ystep = 1/wn^2*(1 - 1/(l2 - l1)*(l2*exp(l1*x) - l1*exp(l2*x)));
ystep_s = sprintf("%s",ystep);
