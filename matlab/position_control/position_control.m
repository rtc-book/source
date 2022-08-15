function position_control(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import elmech.*             % electromechanical system definition
    import utils.*              % utilities like pwm function
    import plotting.colors.*    % RTCBook colors
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
    ts_default = 'T1';              % default elmech system
    tss_default = 'T1ac';            % default elmech system
    source_default = 'current';     % default elmech system
    variant_default = 0;           % default elmech system
    p = inputParser;
    valid_ts = @(x) true;
    valid_tss = @(x) true;
    valid_source = @(x) strcmp(x,'current'); % has to be current source model
    valid_variant = @(x) true;
    addParameter(p,'ts',ts_default,valid_ts);
    addParameter(p,'tss',tss_default,valid_tss);
    addParameter(p,'source',source_default,valid_source);
    addParameter(p,'variant',variant_default,valid_variant);
    parse(p,varargin{:});

    %% Define system
    em = elmech(p.Results.ts,p.Results.tss,p.Results.source,p.Results.variant);
    s = tf([1,0],[1]);              % make s a tf object
    G = em.tf(1)/s;                 % output angular position
    
    %% Design point
    Ts = 0.3;                              % design settling time
    OS = 0.20;                              % design fractional overshoot
    psi_r = -4/Ts;                          % real part
    zeta = -log(OS)/sqrt(pi^2 + log(OS)^2); % damping ratio
    psi_angle = pi - acos(zeta);            % angle
    psi_mag = psi_r/cos(psi_angle);         % magnitude
    psi_i = psi_mag*sin(psi_angle);         % imaginary part
    psi = psi_r + 1j*psi_i;                 % design point
    disp(['zeta = ',num2str(zeta)])
    disp(['psi = ',num2str(psi)])
    
    %% Design proportional controller
    H = tf([1],[1]);                          % feedback transfer function
    figure;
    rlocus(G*H);
    ylim(3*[-1,1]);
    K1 = 9.11e-5;                    % from root locus
    
    %% Design derivative compensator
    theta_c = pi - angle(evalfr(G,psi));
    disp(sprintf('theta_c = %0.3g deg',rad2deg(theta_c)));
    zD = real(psi) - imag(psi)/tan(theta_c);
    disp(sprintf('zD = %0.3g',zD));
    CD_sans = zpk(zD,[],1);
    
    % Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(K1*CD_sans*G*H,'root-locus-PD.txt');
    grid on
    
    % Complete derivative compensation
    K2 = 15;                  % from the root locus
    N_PD = K1*K2*CD_sans;         % PD controller
    GCLPD1 = N_PD*G/(1+N_PD*G*H);   % closed-loop tf

    %% Design integral compensator
%     ZI = -100;                        % compensator zero
%     CI_sans = (s - ZI)/s;           % compensator sans gain
%     figure;
%     rlocus(CI_sans*K1*G*H);
%     xlim([-30,1]);
%     ylim(50*[-1,1]);
%     K2 = 2.24;                     % from root locus
%     N = K1*K2*CI_sans;
    
    %% Closed-loop and discretize system models
%     N = N_PD;
    wc=50;          % control bandwidth
    wc=2*pi*8;      % control bandwidth (Gain crossover frequency)
    Options = pidtuneOptions('DesignFocus','reference-tracking');
    N = pidtune(G,'pidf',wc,Options);
    GCL = N*G/(1+N*G*H);            % closed-loop tf
    T = 5e-3;                       % s ... sample period
    NT = c2d(N,T,'Tustin');         % using Tustin's method
    GT = c2d(G,T,'Tustin');
    HT = c2d(H,T,'Tustin');
    GCLT = NT*GT/(1+NT*GT*HT);      % discrete closed-loop tf
    
    %% Simulate step command output responses
    R_deg = 180;                   % deg ... command angular position
    R_rad = R_deg*pi/180;         % rad
    t = 0:T:0.6;
%     yP = R_rads*step(GCLP,t);
    Theta = R_rad*step(GCL,t);
    ThetaT = R_rad*step(GCLT,t);
    
    %% Control effort
    U_R = NT/(1+NT*GT*HT);              % control effort cl tf, voltage before amplifier
    u = R_rad*step(U_R,t);          % control effort: amplifier input voltage
    u_c = u*em.p.Ka;                % control effort: amplifier output current
    u_v = em.p.R*u_c(1:end-1) + em.p.L*diff(u_c) + em.p.Km*diff(ThetaT); % control effort: amplifier output voltage
%     U_R = N/(1+N*G*H);              % control effort cl tf, voltage before amplifier
%     u = R_rad*step(U_R,t);          % control effort: amplifier input voltage
%     u_c = u*em.p.Ka;                % control effort: amplifier output current
%     u_v = em.p.R*u_c(1:end-1) + em.p.L*diff(u_c) + em.p.Km*diff(Theta); % control effort: amplifier output voltage
    
    %% Plot step responses
    figure;
    subplot(2,1,1)
    plot(t,Theta*180/pi,'linewidth',1); hold on
    plot(t,ThetaT*180/pi,'o','linewidth',1); hold off
    xlabel('time (s)')
    ylabel('step command \Theta_J response (deg)')
    subplot(2,1,2)
    yyaxis left
%     plot(t,u,'linewidth',1); hold on
    stairs(t,u_c,'linewidth',1); hold off
    ylabel('control effort I_S (A)')
    yyaxis right
    stairs(t(1:end-1),u_v,'linewidth',1);
    xlabel('time (s)')
    ylabel('v_S (V)')
    
    %% PI gains
    
%     KP = K1*K2;
%     KI = -ZI*KP;
%     disp(sprintf('KP = %f',KP));
%     disp(sprintf('KI = %f',KI));
    
%     save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
%     save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');


end