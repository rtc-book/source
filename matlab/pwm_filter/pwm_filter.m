clear; close all;
addpath('..')               % to load sibling packages
addpath('../matlab2tikz/src/') 
import elmech.*             % electromechanical system definition
import utils.*              % utilities like pwm function
import plotting.colors.*    % RTCBook colors
colors = plotting.colors(); % ... load them, set as default

% System definition

em = elmech('T1','T1a','voltage','OJ+iL');
sys = em.ss;
wn = em.p.wn;
dcg = em.dc;

%% Bode

W = logspace(log10(wn)-2,log10(wn)+4,100);
[M,P] = bode(sys(1),W); % ΩJ only

figure
semilogx(W/wn,squeeze(mag2db(M/dcg(1))));
grid on;

matlab2tikz('pwm_filter_bode.tex', ...
    'width','\figwidth','height','\figheight' ...
)

%% ΩJ PWM response

%%% ΩJ PWM input

pwmp.amp = 2;                   % V ... PWM amplitude
pwmp.w = wn*[.1,.5,1.0,1.5];              % rad/s ... PWM frequency
pwmp.duty = 0.5;                % duty cycle

kappa = pwmp.amp*pwmp.duty;     % mean pulse-wave
wjs = kappa*dcg(1);             % steady state mean ΩJs

dsb = 1e5;                      % dividing down factor for plots

wlen = length(pwmp.w);
t_a = linspace(0,2*pi/wn*20,1e6);
u_a = zeros(wlen,length(t_a));
for j = 1:wlen
   u_a(j,:) = utils.pwm(t_a,pwmp.amp,pwmp.w(j),pwmp.duty); 
end

u_on = u_a;                     % this is for the following plot only
u_on(u_on == 0) = NaN;          % ditto

figure
for j = 1:wlen
    plot( ...
        downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(j))), ...
        downsample(j*u_on(j,:)/pwmp.amp,round(dsb/pwmp.w(j))) ...
    )
    hold on
end
hold off

matlab2tikz('pwm_filter_input.tex', ...
    'width','\figwidth','height','\figheight' ...
)

%%% ΩJ PWM responses

y_a = zeros(wlen,length(t_a));
for j = 1:wlen
    y_a(j,:) = lsim(sys(1),u_a(j,:),t_a);
end
y_step = pwmp.amp*pwmp.duty*step(sys(1),t_a);

figure
for j = 1:wlen
    plot( ...
        downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(j))), ...
        downsample(y_a(j,:)/dcg(1),round(dsb/pwmp.w(j))), ...
        'displayname',sprintf("Pulse at $\\omega = %3.1f \\omega_n $",pwmp.w(j)/wn) ...
    )
    hold on
end
plot( ...
    downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(1))), ...
    downsample(y_step/dcg(1),round(dsb/pwmp.w(1))), ...
    'displayname','Step $\mu\,u_s\!(t)$' ...
)
hold off
legend('interpreter','latex','location','southeast')

matlab2tikz('pwm_filter_output.tex', ...
    'width','\figwidth','height','\figheight' ...
)

%% iL PWM response

%%% iL PWM input

pwmp.amp = -2;      % V ... PWM amplitude
pwmp.w = 1e0*wn*(1:4);      % rad/s ... PWM frequency
pwmp.duty = 0.5;   % duty cycle

dsb = 1e5;

wlen = length(pwmp.w);
t_a = linspace(0,2*pi/wn*7,1e7);
u_a = zeros(wlen,length(t_a));
for j = 1:wlen
    u_a(j,:) = utils.pwm(t_a,pwmp.amp,pwmp.w(j),pwmp.duty); 
end

%%% iL PWM responses

i_a = zeros(wlen,length(t_a));
for j = 1:wlen
    i_a(j,:) = lsim(sys(2),u_a(j,:),t_a,[40,0]);
end
i_step = lsim(sys(2),pwmp.amp*pwmp.duty*ones(size(t_a)),t_a,[40,0]);

figure
for j = 1:wlen
    plot( ...
        downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(j))), ...
        downsample(i_a(j,:),round(dsb/pwmp.w(j))), ...
        'displayname',sprintf("Pulse at $\\omega = %3.0f \\omega_n $",pwmp.w(j)/wn) ...
    )
    hold on
end
plot( ...
    downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(1))), ...
    downsample(i_step,round(dsb/pwmp.w(1))), ...
    'displayname','Step $\mu\,u_s\!(t)$' ...
)
hold off
legend('interpreter','latex','location','southeast')

% matlab2tikz('pwm_filter_output.tex', ...
%     'width','\figwidth','height','\figheight' ...
% )

%% iL PWM response at a higher PWM frequency

pwmp.amp = 2;      % V ... PWM amplitude
pwmp.w = 1e1*wn*(1:4);      % rad/s ... PWM frequency
pwmp.duty = 0.5;   % duty cycle

dsb = 1e5;

wlen = length(pwmp.w);
t_a = linspace(0,2*pi/wn*5,1e7);
u_a = zeros(wlen,length(t_a));
for j = 1:wlen
   u_a(j,:) = pwm(t_a,pwmp.amp,pwmp.w(j),pwmp.duty); 
end

i_a = zeros(wlen,length(t_a));
for j = 1:wlen
    i_a(j,:) = lsim(sys(2),u_a(j,:),t_a);
end
i_step = pwmp.amp*pwmp.duty*step(sys(2),t_a);

figure
for j = 1:wlen
    plot( ...
        downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(j))), ...
        downsample(i_a(j,:)/dcg(2),round(dsb/pwmp.w(j))), ...
        'displayname',sprintf("Pulse at $\\omega = %3.0f \\omega_n $",pwmp.w(j)/wn) ...
    )
    hold on
end
plot( ...
    downsample(t_a*wn/(2*pi),round(dsb/pwmp.w(1))), ...
    downsample(i_step/dcg(2),round(dsb/pwmp.w(1))), ...
    'displayname','Step $\mu\,u_s\!(t)$' ...
)
hold off
legend('interpreter','latex','location','southeast')

% matlab2tikz('pwm_filter_output.tex', ...
%     'width','\figwidth','height','\figheight' ...
% )
