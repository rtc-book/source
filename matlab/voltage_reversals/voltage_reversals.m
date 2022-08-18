function voltage_reversals(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import elmech.*             % electromechanical system definition
    import utils.*              % utilities like pwm function
    import plotting.colors.*    % RTCBook colors
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
    ts_default = 'T2';              % default elmech system
    tss_default = 'T2a';            % default elmech system
    source_default = 'voltage';     % default elmech system
    variant_default = 'OJ+iL';      % default elmech system
    p = inputParser;
    valid_ts = @(x) true;
    valid_tss = @(x) true;
    valid_source = @(x) strcmp(x,'voltage'); % has to be voltage source model
    valid_variant = @(x) true;
    addParameter(p,'ts',ts_default,valid_ts);
    addParameter(p,'tss',tss_default,valid_tss);
    addParameter(p,'source',source_default,valid_source);
    addParameter(p,'variant',variant_default,valid_variant);
    parse(p,varargin{:});

    %% Define system
    em = elmech(p.Results.ts,p.Results.tss,p.Results.source,p.Results.variant);
    sys = em.ss;
    wn = em.p.wn;

    %% Voltage reversals and iL response

    pwmp.amp = 2;       % V ... PWM amplitude
    pwmp.w = wn;        % rad/s ... PWM frequency
    pwmp.duty = 0.5;    % duty cycle

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
    disp(em.v)
    save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
    save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');

    figure
    yyaxis left
    plot(t_a*wn/(2*pi),u_a);
    hold on
    yyaxis right
    plot(t_a*wn/(2*pi),i_a);

end