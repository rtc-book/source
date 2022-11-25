function voltage_reversals(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import elmech.*             % electromechanical system definition
    import utils.*              % utilities like pwm function
    import plotting.colors.*    % RTCBook colors
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
    ts_default = 'T1';              % default elmech system
    tss_default = 'T1a';            % default elmech system
    source_default = 'voltage';     % default elmech system
    variant_default = 'OJ+iL+vL';      % default elmech system
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
    pwmp.w = wn/20;        % rad/s ... PWM frequency
    pwmp.duty = 0.5;    % duty cycle

    t_a = linspace(0,2*pi/pwmp.w,1e3);
    u_a = zeros(1,length(t_a));
    for i = 1:length(t_a)
       u_a(1,i) = -pwmp.amp/2+pwm(t_a(i),pwmp.amp,pwmp.w,pwmp.duty); 
    end

    y = lsim(sys,u_a(1,:),t_a,[0,0]);
    O_a = y(:,1);
    i_a = y(:,2);
    v_a = y(:,3);
%     T_a = y(:,3);
    
    t_an = t_a.'*wn/(2*pi);
    u_an = u_a.';
    O_an = O_a;
    i_an = i_a;
    v_an = v_a;
%     T_an = T_a;
    dat_u = [t_an,u_an];
    dat_O = [t_an,O_an];
    dat_i = [t_an,i_an];
    dat_v = [t_an,v_an];
%     dat_T = [t_an,T_an];
    disp(em.v)
    save(strcat(em.v,'_u','_make.dat'),'dat_u','-ascii');
    save(strcat(em.v,'_O','_make.dat'),'dat_O','-ascii');
    save(strcat(em.v,'_i','_make.dat'),'dat_i','-ascii');
    save(strcat(em.v,'_v','_make.dat'),'dat_v','-ascii');
%     save(strcat(em.v,'_T','_make.dat'),'dat_T','-ascii');
    
    figure
    yyaxis left
    plot(t_a*wn/(2*pi),v_a);
    hold on
    yyaxis right
    plot(t_a*wn/(2*pi),O_a);
    
%     figure
%     plot(t_a*wn/(2*pi),T_a.*O_a);hold on
%     plot(t_a*wn/(2*pi),cumtrapz(t_a*wn/(2*pi),T_a.*O_a));

    figure
    yyaxis left
    plot(t_a*wn/(2*pi),u_a);
    hold on
    yyaxis right
    plot(t_a*wn/(2*pi),i_a);

end