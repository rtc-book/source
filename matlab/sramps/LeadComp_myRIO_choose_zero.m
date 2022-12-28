clear
close all

%---plant
Kvi =   0.41;         % Amplifier gain (A/V)
Kt=     0.11;         % Torque constant (Kt=0.11 Nm/A)
K =     Kvi*Kt;       % (N-m/V)
Jp =    3.8e-4;       % moment of inertia (N-m-s^2/rad) (flywheel alone)
plant=zpk([],[0,0],K/Jp);     %---plant
Ts=0.005;

% load('Lab.mat')
%---phase lead compensation
locus=figure;
target=-20+22j;
% target=-40+15j;
zc=20 ;
% Kc=10;
v_zc=target+zc;
v_pato=target;
ang_pc=pi+angle(v_zc)-2*angle(v_pato);
pc=imag(target)/tan(ang_pc)-real(target);
v_pc=target+pc;
Kc=abs(v_pato)^2*abs(v_pc)/abs(v_zc)/(K/Jp);
lead=zpk([-zc],[-pc],Kc);    %---lead compensator
gh=series(lead,plant);
%--- goal(zeta_goal,zeta_wn_goal)
goal(.5,16);
rlocus(gh); 
a=axis; a(1)=-50; a(2)=50;  a(3)=-50; a(4)=50; axis(a);
axis equal

%     hold on    
%     plot([-1,-1],[-20,20],'r--')
%     plot([0,-20*0.4],[0,20*sin(acos(0.4))],'r--')
%     plot([0,-20*0.4],[0,-20*sin(acos(0.4))],'r--')
% pause
[r,k]=rlocus(gh,1);
title('lead compensator')
plot(r,'gs',    'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',9)
pause

stepr=figure; 
sys=feedback(gh,1);
step(sys);
    title('lead compensator')
    hold on
    plot([0,8],[1.02,1.02],'r--');
    plot([0,8],[.98,.98],'r--');
    plot([4,4],[0,10],'r--');
    plot([0,8],[1.25,1.25],'r--');
    
%---discrete system
figure
dsys=c2d(lead,Ts);
step(lead, dsys)

    
