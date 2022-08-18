close all
clear

%---Script #1:  PIDF design
 
%---PIDF controller for DC motor position control
%---plant
T=.005;               % BTI
Kvi =   0.41;         % Amplifier gain (A/V)
Kt=     0.11;         % Torque constant (Kt=0.11 Nm/A)
K =     Kvi*Kt;       % (N-m/V)
Jp =    3.8e-4;       % moment of inertia (N-m-s^2/rad) (flywheel alone)
B =     8e-5;
B=0;
plant=zpk([],[0,-B/Jp],K/Jp);     %---plant P(s)/Vda(s)
plantd=c2d(plant,T,'tustin');

%---design PIDF controller 
wc=50;          % control bandwidth
wc=2*pi*8;      % control bandwidth (Gain crossover frequency)
Options = pidtuneOptions('DesignFocus','reference-tracking');
Cp = pidtune(plant,'pid',wc,Options) 
Cdp=c2d(Cp,T,'tustin'); %---controller in parallel form

%---convert controller to discrete-time biquads
Cd=tf(Cdp);             %---convert to transfer function
[b,a]=tfdata(Cd,'v')    %---in vector form, rather that cell arrays
sos=tf2sos(b,a);        %---extract the biquads

% %---write controller to C header
% HeaderFileName = '/Users/garbini/Courses/ME477_ME599/myRio/workspace/Lab8_RnD_newTable/myPIDF.h';
% fid=fopen(HeaderFileName,'W');
% % fid=1;
% comment=['PIDF position control, wc = ',num2str(wc),' r/s'];
% sos2header(fid, sos, 'PIDF', T, comment);
% fclose(fid);

%---Predict time and frequency responses
XoXref_sys=feedback(series(Cp,plant),1);
XoXref_sysd=feedback(series(Cdp,plantd),1);
ToXref_sys=feedback(Cp,plant);
ToXref_sysd=feedback(Cdp,plantd);

scrsz = get(groot,'ScreenSize');
Lab8_response=figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)]);
subplot(411)
    step(XoXref_sys,XoXref_sysd,50*T)
    title('X/Xref')
subplot(412)
%     step(ToXref_sys,ToXref_sysd,50*T)
    title('T/Xref')
    
subplot(212)
    margin(series(plant,Cp))   

    