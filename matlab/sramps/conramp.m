% Comparison of theoretical profile and myRIO PD control experiment
clear
close all;

%---load experiment
% load 'Lab_1_50.mat'  %---the pauses are at successive angles of 1/8 rev.
% load 'Lab_50_20.mat'  %---the pauses are at successive angles of 1/8 rev.
% load 'Lab_10_30.mat'  %---the pauses are at successive angles of 1/8 rev.
load 'Lab.mat'
[nseg,nc]=size(mySegs);
ntot=length(position);

range=1:length(t);

%---pland & control
lead=zpk([-zc],[-pc],kc);
Kvi =   0.41;         % Amplifier gain (A/V)
Kt=     0.11;         % Torque constant (Kt=0.11 Nm/A)
K =     Kvi*Kt;       % (N-m/V)
Jp =    3.8e-4;       % moment of inertia (N-m-s^2/rad) (flywheel alone)
% B=8e-5;@
B=0.;

plant=zpk([],[0,-B/Jp],K/Jp);     %---plant
T0X_sys=feedback(lead,plant);

T=0.005;
[xa,x0,iseg,itime,done]=Sramps(mySegs, -1, nseg, -1, T, 0,0);

for i=1:ntot
    [xa,x0,iseg,itime,done]=Sramps(mySegs, iseg, nseg, itime, T, xa,x0);
    r(i)=xa;
    ta(i)=(i-1)*T;
end
y=lsim(T0X_sys*K,r*2*pi,ta);        %--Nm/r

%---plot d/a voltage
plot(ta(range),torque(range)/Kt/Kvi,'.')

%---plot position and torque.
figure
subplot(211)
    plot(ta(range),r(range),t(range),position(range)/2/pi,'r.')
    grid
    xlabel('time - s')
    ylabel('position - rev')
    title(['Profile comparison:   zc = ',num2str(zc),...
                               ', pc = ',num2str(pc), ...
                               ', K = ', num2str(kc),' V_{DA}/m'])
    legend('Reference Position','Actual Position','Location','NorthWest')
subplot(212)
    plot(ta(range),torque(range),'.',ta(range),y(range))
    xlabel('time - s')
    ylabel('Torque - Nm')
    title('Torque comparison')
    legend('Reference Position','Actual Position')

return