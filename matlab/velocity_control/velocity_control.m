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
    s = tf([1,0],[1]);              % make s a tf object
    G = em.tf;                      % output angular velocity
    
    %% Design proportional controller
    H = 1;                          % feedback transfer function
    figure;
    rlocus(G*H);
    ylim(10*[-1,1])
    K1 = 0.005;                    % from root locus
    GCLP = K1*G/(1+K1*G*H);         % closed-loop tf

    %% Design integral compensator
    ZI = -5;                        % compensator zero
    CI_sans = (s - ZI)/s;           % compensator sans gain
    figure;
    rlocus(CI_sans*K1*G*H);
    ylim(10*[-1,1])
    K2 = 1;                     % from root locus
    GCLPI = K1*K2*CI_sans*G/(1+K1*K2*CI_sans*G*H);         % closed-loop tf
    
    %% Simulate step command responses
    t = linspace(0,1,200);
    yP = step(GCLP,t);
    yPI = step(GCLPI,t);
    
    %% Plot step responses
    figure;
    plot(t,yP,t,yPI);
    xlabel('time (s)')
    ylabel('step command response')
    
%     save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
%     save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');


end