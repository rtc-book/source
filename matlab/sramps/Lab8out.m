% Comparison of theoretical profile and myRIO PD control experiment
clear
close all;

%---load experiment
load 'Lab8.mat'
ntot=length(position);
t=0:T:(ntot-1)*T;
range=1:ntot;

%---plant & control
[b,a]=sos2tf(pidf');
pidfd=tf(b,a,T);      % (Vda Volts)/(error radian)
Kvi =   0.41;         % Amplifier gain (A/V)
Kt=     0.11;         % Torque constant (Kt=0.11 Nm/A)
K =     Kvi*Kt;       % (N-m/V)
Jp =    3.8e-4;       % moment of inertia (N-m-s^2/rad) (flywheel alone)
B=8e-5;

plant=zpk([],[0,-B/Jp],K/Jp);     %---plant
plantd=c2d(plant,T,'tustin');

ToRef_sys=feedback(pidfd,plantd);
PoRef_sys=feedback(series(pidfd,plantd),1);
torque_model=lsim(ToRef_sys*K,pathref,t);      %--Nm/r
position_model=lsim(PoRef_sys,pathref,t);      %--revs

%---plot d/a voltage
plot(t(range),torque(range)/Kt/Kvi,'.')

%---plot position and torque.
scrsz = get(groot,'ScreenSize');
Lab8_output=figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)]);
subplot(211)
    plot(   ...
        t(range),pathref(range)/2/pi, ...
        t(range),position(range)/2/pi,'r.', ...
        t(range),position_model(range)/2/pi,'g-' ...
    )
    grid
    xlabel('time - s')
    ylabel('position - rev')
    title(['Profile comparison; Designed - ',headerTime, ...
            '.  My name: ',myName]);
    legend( 'Reference Position', ...
            'Actual Position',...
            'Predicted Position', ...
            'Location', 'South')
        
subplot(413)
    plot(   ...
        t(range),pathref(range)/2/pi-position(range)/2/pi,'r.', ...
        t(range),pathref(range)/2/pi-position_model(range)/2/pi,'b-' )
    xlabel('time - s')
    ylabel('Position Error - rev')
    title('Control Error');

subplot(414)
    plot(t(range),torque(range),'.',t(range),torque_model(range))
    xlabel('time - s')
    ylabel('Torque - Nm')
    title('Torque comparison')
    legend('Actual Torque','Predicted Torque')

tf(pidf(1:3)',pidf(4:6)',T)  

return