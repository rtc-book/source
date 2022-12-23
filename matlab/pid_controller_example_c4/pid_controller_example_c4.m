function pi_controller_example_c4(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define system
    GP = tf([25],[1,6,25]);
    H = tf([1],[1]);
    
    %% Design point
    Ts = 0.54;                              % design settling time
    OS = 0.20;                              % design fractional overshoot
    psi_r = -4/Ts;                          % real part
    zeta = -log(OS)/sqrt(pi^2 + log(OS)^2); % damping ratio
    psi_angle = pi - acos(zeta);            % angle
    psi_mag = psi_r/cos(psi_angle);         % magnitude
    psi_i = psi_mag*sin(psi_angle);         % imaginary part
    psi = psi_r + 1j*psi_i;                 % design point
    disp(['zeta = ',num2str(zeta)])
    disp(['psi = ',num2str(psi)])
    
    %% Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(GP*H,'root-locus-P.txt');
    grid on
    
    %% Define the closed-loop transfer function
    K1 = 0.734;               % from root locus
    GCLP = K1*GP/(1+K1*GP*H);   % closed-loop tf
    
    %% Simulate the step response
    t = linspace(0,2,200);  % time array
    yP = step(GCLP,t);        % step response simulation
    
    %% Plot step response
    figure
    plot(t,yP);
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',yP];
    save('step-response-P.txt','d','-ascii');
    
    %% Derivative compensation
    theta_c = pi - angle(evalfr(GP,psi));
    disp(sprintf('theta_c = %0.3g deg',rad2deg(theta_c)));
    zD = real(psi) - imag(psi)/tan(theta_c);
    disp(sprintf('zD = %0.3g',zD));
    CD_sans = zpk(zD,[],1);
    
    % Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(K1*CD_sans*GP*H,'root-locus-PD.txt');
    grid on
    
    % Complete derivative compensation
    K2 = 0.48;                  % from the root locus
    GCPD = K1*K2*CD_sans;         % PD controller
    GCLPD1 = GCPD*GP/(1+GCPD*GP*H);   % closed-loop tf
    
    % Simulate the step response
    yPD1 = step(GCLPD1,t);        % step response simulation
    
    %% Integral compensation
    zI = -2;
    CI_sans = tf([1,-zI],[1,0]);
    
    % Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(GCPD*CI_sans*GP*H,'root-locus-PID.txt');
    grid on
    
    % Complete integral compensation
    K3 = 1.21;
    GCPID = K1*K2*K3*CD_sans*CI_sans;
    GCLPID1 = GCPID*GP/(1+GCPID*GP*H);
    
    % Simulate the step response
    yPID1 = step(GCLPID1,t);        % step response simulation
    
    %% Plot step responses together
    figure
    plot(t,yP);hold on
    plot(t,yPD1);
    plot(t,yPID1);hold off
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',yP,yPD1,yPID1];
    save('step-response-all.txt','d','-ascii');
    
    %% Compute transient response characteristics
    S = stepinfo(yPID1,t);
    disp(sprintf('Ts = %0.2f sec',S.SettlingTime))
    disp(sprintf('OS = %0.2f percent',S.Overshoot))
    
    %% PID gains
    disp(['Kp = ',num2str(-K1*K2*K3*(zD+zI))]);
    disp(['Ki = ',num2str(K1*K2*K3*(zD*zI))]);
    disp(['Kd = ',num2str(K1*K2*K3)]);
end
