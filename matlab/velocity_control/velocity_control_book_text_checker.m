% Copied and pasted from the text just to check things
clear;close all;

Ts = 0.2;                     % s ... design settling time
psi_r = -4 / Ts;              % real part of design point psi

load("../elmech_params/elmech_params_T1a.mat");

tau = p.J / p.b;                         % time constant
 GP = tf([p.Ka * p.Km / p.b], [tau, 1]);  % electromech. system
                                          % transfer func.
H = tf([1], [1]); % feedback transfer function

figure;
 rlocus(GP * H);                 % root locus
 xlim([-40, 0]);
 
K1 = 9.08e-3; % from root locus

ZI = -20;
s = tf([1, 0], [1]);
CI_sans = (s - ZI) / s;
% compensator zero
% s as tf object
% compensator sans gain

figure;
 rlocus(CI_sans * K1 * GP * H);
 xlim([-40, 0]);
 
 K2 = 2.15; % from root locus
 
 GC = K1 * K2 * CI_sans;
 
 GCL = GC * GP / (1 + GC * GP * H); % closed-loop tf
 
 T = 5e-3;                                 % s ... sample period
 GCd = c2d(GC, T, 'Tustin');               % using Tustin's method
 GPd = c2d(GP, T, 'Tustin');
 Hd = c2d(H, T, 'Tustin');
 GCLd = GCd * GPd / (1 + GCd * GPd * Hd);  % discrete closed-loop tf
 
 R_rpm = 1000;
R_rads = R_rpm * 2 * pi / 60;
t = 0:T:0.6;
Omega = R_rads * step(GCL, t);
Omegad = R_rads * step(GCLd, t);  % discrete step response

U_R=GCd/(1+GCd*GPd*Hd); %V,controleffortcltf,ampl.in. 
u = R_rads * step(U_R, t); % V, amplifier input voltage
u_c = u * p.Ka; % amplifier output current

 u_v = p.R * u_c(1:end - 1) + ... % V, amplifier output voltage
       p.L * diff(u_c) +  ...
       p.Km * Omegad(1:end - 1);
   KP = K1 * K2;
 KI = -ZI * KP;