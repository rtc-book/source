function velocity_open_loop_voltage(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import elmech.*             % electromechanical system definition
    import utils.*              % utilities like pwm function
    import plotting.colors.*    % RTCBook colors
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
    ts_default = 'T1';              % default elmech system
    tss_default = 'T1ac';            % default elmech system
    source_default = 'voltage';     % default elmech system
    variant_default = 'OJ+iL';           % default elmech system
    p = inputParser;
    valid_ts = @(x) true;
    valid_tss = @(x) true;
    valid_source = @(x) strcmp(x,'voltage'); % has to be current source model
    valid_variant = @(x) true;
    addParameter(p,'ts',ts_default,valid_ts);
    addParameter(p,'tss',tss_default,valid_tss);
    addParameter(p,'source',source_default,valid_source);
    addParameter(p,'variant',variant_default,valid_variant);
    parse(p,varargin{:});

    %% Define system
    em = elmech(p.Results.ts,p.Results.tss,p.Results.source,p.Results.variant);
    G = em.tf(1);                      % output angular velocity
    
    %% Simulate step output responses
    R_rpm = 1000;                   % RPM ... command angular velocity
    R_rads = R_rpm*2*pi/60;         % rad/s
    m = (em.p.Km^2 + em.p.b*em.p.R)/em.p.Km*R_rads;      % A ... current step to achieve R
    M = m/em.p.Ka;                  % V ... voltage step into amp to achieve R
    t = linspace(0,.3,200);
    Omega = M*step(G,t);
    
    %% Required current
    m_vec = m*ones(size(t));
    G_current = em.tf(2);                      % output current
    u_i = M*step(G_current,t); % amplifier output current
    
    %% Plot step responses
    figure;
    subplot(2,1,1)
    plot(t,Omega*60/(2*pi),'linewidth',1);
    xlabel('time (s)')
    ylabel('step command \Omega_J response (rpm)')
    subplot(2,1,2)
    yyaxis left
    plot(t,m_vec,'linewidth',1);
    ylabel('control effort V_S (V)')
    ylim([0,m*2])
    yyaxis right
    plot(t,u_i,'-','linewidth',1);
    xlabel('time (s)')
    ylabel('i_S (A)')
    
    disp(sprintf('V_S = %f',m));
    
%     save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
%     save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');


end