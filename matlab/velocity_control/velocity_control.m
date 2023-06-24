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
    GP = em.p.Ka*em.tf(1);                   % output angular velocity
    
    %% Design point
    Ts = 0.2;                       % sec ... design settling time
    psi_r = -4/Ts;                  % real part of design point psi
    fprintf('Re(psi) = %f\n',psi_r);
    
    %% Design proportional controller
    H = tf([1],[1]);                % feedback transfer function
    figure;
    [r,k] = root_locus_data(GP*H,'root-locus-P.txt');
    grid on
    xlim([-40,0]);
    K1 = 9.08e-3;                     % from root locus

    %% Design integral compensator
    ZI = -20;                        % compensator zero
    s = tf([1,0],[1]);              % s as tf object
    CI_sans = (s - ZI)/s;           % compensator sans gain
    figure;
    [r,k] = root_locus_data(CI_sans*K1*GP*H,'root-locus-PI.txt');
    xlim([-40,0]);
    K2 = 2.15;                     % from root locus
    GC = K1*K2*CI_sans;
    
    %% Close loop and discretize system models
    GCL = GC*GP/(1+GC*GP*H);            % closed-loop tf
    T = 5e-3;                       % s ... sample period
    GCd = c2d(GC,T,'Tustin');         % using Tustin's method
    GPd = c2d(GP,T,'Tustin');
    Hd = c2d(H,T,'Tustin');
%     GCLd = GCd*GPd/(1+GCd*GPd*Hd);      % discrete closed-loop tf
    GCLd = feedback(GCd*GPd,Hd);      % discrete closed-loop tf
    
    %% Simulate step command output responses
    R_rpm = 1000;                   % RPM ... command angular velocity
    R_rads = R_rpm*2*pi/60;         % rad/s
    t = 0:T:0.4;
%     yP = R_rads*step(GCLP,t);
    Omega = R_rads*step(GCL,t);
    Omegad = R_rads*step(GCLd,t);
    
    %% Control effort
    U_R = GCd/(1+GCd*GPd*Hd);          % control effort cl tf, amp input voltage
    u = R_rads*step(U_R,t);         % amplifier input voltage
    u_c = u*em.p.Ka;                % amplifier output current
    u_v = em.p.R*u_c(1:end-1) + ... % amplifier output voltage
        em.p.L*diff(u_c) +  ...
        em.p.Km*Omegad(1:end-1);
    
    %% Plot step responses
    figure;
    subplot(2,1,1)
    plot(t,Omega*60/(2*pi),'linewidth',1); hold on
    plot(t,Omegad*60/(2*pi),'o','linewidth',1); hold off
    xlabel('time (s)')
    ylabel('step command \Omega_J response (rpm)')
    subplot(2,1,2)
    yyaxis left
%     plot(t,u,'linewidth',1); hold on
    stairs(t,u_c*1e3,'linewidth',1); hold off
    ylabel('control effort I_S (mA)')
    yyaxis right
    stairs(t(1:end-1),u_v,'linewidth',1);
    xlabel('time (s)')
    ylabel('v_S (V)')
    
    %% Save step plot data
    d = [t.',Omega*60/(2*pi),Omegad*60/(2*pi)];
    save('step-response-Omega.txt','d','-ascii');
    d = [t.',u_c*1e3];
    save('step-response-uc.txt','d','-ascii');
    u_v(end+1) = u_v(end); % for plot
    d = [t.',u_v];
    save('step-response-uv.txt','d','-ascii');
    
    %% PI gains
    
    KP = K1*K2;
    KI = -ZI*KP;
    disp(sprintf('KP = %f',KP));
    disp(sprintf('KI = %f',KI));
    
    %% Transient response characteristics
    
    si = stepinfo(Omegad,t);
    disp(sprintf('Settling time: %f s',si.SettlingTime));
    
%     save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
%     save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');

    
end