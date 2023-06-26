function position_control(varargin)
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
    G = em.p.Ka*em.tf/s;                    % plant tf, Theta/U_a
    H = tf([1],[1]);                % unity feedback
    
    %% Design PIDF controller with pidtune
    Tr = 0.04;                      % design closed-loop rise time (conservative)
    wc=2/Tr;                        % control bandwidth (gain crossover frequency)
    options = pidtuneOptions('DesignFocus','reference-tracking');
    N = pidtune(G*H,'pidf',wc,options);
    GCL = N*G/(1+N*G*H);            % closed-loop tf Theta/U_a
    
    %% Discretize transfer functions
    T = 5e-3;                       % s ... sample period (BTI)
    NT = c2d(N,T,'Tustin');         % using Tustin's method
    GT = c2d(G,T,'Tustin');
    HT = c2d(H,T,'Tustin');
    GCLT = NT*GT/(1+NT*GT*HT);      % discrete closed-loop tf
    
    %% Simulate step command output responses
    R_deg = 25;                     % deg ... command angular position
    R_rad = R_deg*pi/180;           % rad
    t = 0:T:0.2;
    Theta = R_rad*step(GCL,t);
    ThetaT = R_rad*step(GCLT,t);
    
    %% Control effort
    U_R = NT/(1+NT*GT*HT);          % control effort cl tf, amp input voltage
    u = R_rad*step(U_R,t);          % amplifier input voltage
    u_c = u*em.p.Ka;                % amplifier output current
    u_v = em.p.R*u_c(1:end-1) + ... % amplifier output voltage
        em.p.L*diff(u_c) + ...
        em.p.Km*diff(ThetaT);
    
    %% Plot step responses
    figure;
    subplot(2,1,1)
    plot(t,Theta*180/pi,'linewidth',1); hold on
    plot(t,ThetaT*180/pi,'o','linewidth',1); hold off
    xlabel('time (s)')
    ylabel('step command \Theta_J response (deg)')
    subplot(2,1,2)
    yyaxis left
    stairs(t,u_c,'linewidth',1); hold off
    ylabel('control effort I_S (A)')
    yyaxis right
    stairs(t(1:end-1),u_v,'linewidth',1);
    xlabel('time (s)')
    ylabel('v_S (V)')
    
    %% Save step plot data
    d = [t.',Theta*180/pi,ThetaT*180/pi];
    save('step-response-Theta.txt','d','-ascii');
    d = [t.',u_c*1e3];
    save('step-response-uc.txt','d','-ascii');
    u_v(end+1) = u_v(end); % for plot
    d = [t.',u_v];
    save('step-response-uv.txt','d','-ascii');
    
    %% Rise time
    si = stepinfo(Theta,t);
    fprintf( ...
        'closed-loop rise time T_r = %f seconds\n', ...
        si.RiseTime ...
    );
    
    %% Convert discrete controller to biquads
    [b,a] = tfdata(NT,'v');         % in vector form 'v'
    sos = tf2sos(b,a);              % extract the biquads
    
    %% Write controller to C header
    header_filename = 'myPIDF.h';
    fid = fopen(header_filename,'W');
    comment = ['PIDF position control, wc = ',num2str(wc),' r/s'];
    sos2header(fid,sos,'PIDF',T,comment);
    fclose(fid);
    
end