function velocity_control_symbolic(varargin)
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
    syms Ka Km b R J Kp Ki positive
    syms s
    em = elmech(p.Results.ts,p.Results.tss,p.Results.source,p.Results.variant);
    G = em.tf_(1);              % plant with amplifier
    
    %% Close loop symbolically
    H = 1;                      % unity feedback
    N = Kp + Ki/s;
    Y_R = simplify(N*G/(1+N*G*H));
    disp(Y_R)
    
    %% extract parameters
    [n,d] = numden(Y_R);
    dco = coeffs(d,s);
    nco = coeffs(n,s);
    wn = sqrt(dco(1)/dco(3))
    z = simplify(dco(2)/dco(3)/(2*wn))
    tau = nco(2)/nco(1)
    Y_R_sans = (tau*s+1)/(s^2+2*z*wn*s+wn^2);
    K = simplifyFraction(Y_R/Y_R_sans,'Expand',true)
    % check that we have correctly extracted parameters
    if isequal(Y_R,simplify(K*Y_R_sans))
        disp('checks out')
    else
        error('something is wrong with equality check')
    end
end