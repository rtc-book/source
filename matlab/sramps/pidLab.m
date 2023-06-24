clear
close all

%---PI Motor controller parameters
Kvi =   0.41;         % Amplifier gain (A/V)
Kt=     0.11;         % Torque constant (Kt=0.11 Nm/A)
K =     Kvi*Kt;       % (N-m/V)
Jp =    3.4e-4;       % moment of inertia (N-m-s^2/rad) (flywheel alone)
% Jp =    4.2e-4;       % moment of inertia (N-m-s^2/rad)

plant=zpk([],[0, 0],K/Jp);

C=pidtune(plant,'PIDF')
Kp = 0.0014;
Ki = 6.55e-05;
Kd = 0.00734;
Tf=0.183;
con=pid(Kp,Ki,Kd,Tf);
gh=series(con,plant)
sys=feedback(gh,1);
step(sys)
