clear; close all;
addpath('..')               % to load sibling packages
import elmech.*             % electromechanical system definition
import utils.*              % utilities like pwm function
import plotting.colors.*    % RTCBook colors
colors = plotting.colors(); % ... load them, set as default

% System definition

em = elmech('T1','voltage','OJ+iL');
sys = em.ss;
wn = em.p.wn;
dcg = em.dc;

%% Voltage reversals and iL response

pwmp.amp = 2;       % V ... PWM amplitude
pwmp.w = wn;        % rad/s ... PWM frequency
pwmp.duty = 0.5;    % duty cycle

wlen = length(pwmp.w);
t_a = linspace(0,1.5*2*pi/wn,1e3);
u_a = zeros(1,length(t_a));
for i = 1:length(t_a)
   u_a(1,i) = -pwmp.amp/2+pwm(t_a(i),pwmp.amp,pwmp.w,pwmp.duty); 
end

i_a = lsim(sys(2),u_a(1,:),t_a,[0,0]);

t_an = t_a.'*wn/(2*pi);
u_an = u_a.';
i_an = i_a;

dat_u = [t_an,u_an];
dat_i = [t_an,i_an];

save('voltage_reversals_u.dat','dat_u','-ascii');
save('voltage_reversals_i.dat','dat_i','-ascii');

figure
yyaxis left
plot(t_a*wn/(2*pi),u_a);
hold on
yyaxis right
plot(t_a*wn/(2*pi),i_a);
