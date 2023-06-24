clear;close all

load("../elmech_params/elmech_params_T1a.mat");

tau = p.J / p.B;                        % time constant
 G = tf([p.Ka * p.Km / p.B], [tau, 1]);  % electromech. system
 
 s = tf([1, 0], [1]);
GP = G / s;
H = tf([1], [1]);
% make s a tf object
% plant tf, Theta/U_a
% unity feedback

Tr = 0.04; % s, design closed-loop rise time (conservative)
wc=2 / Tr; % rad/s, control bandwidth (gain crossover frequency) 
options = pidtuneOptions('DesignFocus', 'reference-tracking');
GC = pidtune(GP * H, 'PIDF', wc, options); 
GCL=GC*GP/(1+GC*GP*H); %closed-looptfTheta/U_a

T = 5e-3;                                 % s, sample period (BTI)
                      GCd = c2d(GC, T, 'Tustin');               % using Tustin's method
                      GPd = c2d(GP, T, 'Tustin');
                      Hd = c2d(H, T, 'Tustin');
GCLd = GCd * GPd / (1 + GCd * GPd * Hd); % discrete closed-loop tf

R_deg = 90;                     % deg, command angular position
                      R_rad = R_deg * pi / 180;       % rad
                      t = 0:T:0.2;
                      Theta = R_rad * step(GCL, t);
ThetaT = R_rad * step(GCLd, t);

U_R=GCd/(1+GCd*GPd*Hd); %V,controleffortcltf,ampl.in. 
u = R_rad * step(U_R, t); % V, amplifier input voltage
u_c = u * p.Ka; % A, amplifier output current

u_v = p.R * u_c(1:end - 1) + ...   % amplifier output voltage
                            p.L * diff(u_c) + ...
                            p.Km * diff(ThetaT);
                        
                        
    figure;
    subplot(2,1,1)
    plot(t,Theta*180/pi,'linewidth',1); hold on
    plot(t,ThetaT*180/pi,'o','linewidth',1); hold off
    xlabel('time (s)')
    ylabel('step command \Theta_J response (deg)')
    subplot(2,1,2)
    yyaxis left
    stairs(t,u_c,'linewidth',1); hold off
    ylabel('control effort I_S (A)')
    yyaxis right
    stairs(t(1:end-1),u_v,'linewidth',1);
    xlabel('time (s)')
    ylabel('v_S (V)')