function velocity_control(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import elmech.*             % electromechanical system definition
    import utils.*              % utilities like pwm function
    import plotting.colors.*    % RTCBook colors
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
    ts_default = 'T1';              % default elmech system
    tss_default = 'T1a';            % default elmech system
    source_default = 'current';     % default elmech system
    variant_default = 'OJ+iL';           % default elmech system
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
    G = em.tf(1);                      % output angular velocity
    
    %% Design proportional controller
    H = tf([1],[1]);                          % feedback transfer function
    figure;
    rlocus(G*H);
%     ylim(10*[-1,1])
    K1 = 0.001;                    % from root locus
%     GCLP = K1*G/(1+K1*G*H);         % closed-loop tf

    %% Design integral compensator
    ZI = -100;                        % compensator zero
    CI_sans = (s - ZI)/s;           % compensator sans gain
    figure;
    rlocus(CI_sans*K1*G*H);
    K2 = 1;                     % from root locus
    N = K1*K2*CI_sans;
    
    %% Closed-loop and discretize system models
    
    GCL = N*G/(1+N*G*H);            % closed-loop tf
    T = 5e-3;                       % s ... sample period
    NT = c2d(N,T,'Tustin');         % using Tustin's method
    GT = c2d(G,T,'Tustin');
    HT = c2d(H,T,'Tustin');
    GCLT = NT*GT/(1+NT*GT*HT);      % discrete closed-loop tf
    
    %% Simulate step command output responses
    R_rpm = 1000;                   % RPM ... command angular velocity
    R_rads = R_rpm*2*pi/60;         % rad/s
    t = 0:T:0.6;
%     yP = R_rads*step(GCLP,t);
    Omega = R_rads*step(GCL,t);
    OmegaT = R_rads*step(GCLT,t);
    
    %% Control effort
    U_R = NT/(1+NT*GT*HT);              % control effort cl tf, voltage before amplifier
    u = R_rads*step(U_R,t);         % control effort: amplifier input voltage
    u_c = u*em.p.Ka;                % control effort: amplifier output current
    u_v = em.p.R*u_c(1:end-1) + em.p.L*diff(u_c) + em.p.Km*OmegaT(1:end-1); % control effort: amplifier output voltage
    
    %% Plot step responses
    figure;
    subplot(2,1,1)
    plot(t,Omega*60/(2*pi),'linewidth',1); hold on
    plot(t,OmegaT*60/(2*pi),'o','linewidth',1); hold off
    xlabel('time (s)')
    ylabel('step command \Omega_J response (rpm)')
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
    
    KP = K1*K2;
    KI = -ZI*KP;
    disp(sprintf('KP = %f',KP));
    disp(sprintf('KI = %f',KI));
    
%     save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
%     save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');


end