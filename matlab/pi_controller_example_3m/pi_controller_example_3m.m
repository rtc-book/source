function pi_controller_example_3m(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define system
    GP1 = tf([10],[1,10]);		% first part of GP
    GP2 = tf([3,45],[1,10,50]);	% second part
    GP = GP1*GP2;				% combine transfer functions
    
    %% Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(GP,'root-locus-P.txt');
    grid on
    
    %% Define the closed-loop transfer function
    K = 1.65;               % from root locus
    GCLP = K*GP/(1+K*GP);   % closed-loop tf
    
    %% Simulate the step response
    t = linspace(0,3,200);  % time array
    yP = step(GCLP,t);        % step response simulation
    
    %% Plot step response
    figure
    plot(t,yP);
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',yP];
    save('step-response-P.txt','d','-ascii');
    
    %% Integral compensation
    CI = tf([1,1],[1,0]);
    GC = K*CI;
    GCLPI = GC*GP/(1+GC*GP);	% closed-loop tf for PI control
    
    %% Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(CI*GP,'root-locus-PI1.txt');
    grid on
    
    %% Simulate the step response
    yPI1 = step(GCLPI1,t);        % step response simulation
    
    %% Faster integral compensation
    CI2 = tf([1,4],[1,0]);
    K2 = 1.45;
    GC2 = K2*CI2;
    GCLPI2 = GC2*GP/(1+GC2*GP);
    
    %% Simulate the step response
    yPI2 = step(GCLPI2,t);        % step response simulation
    
    %% Plot step responses together
    figure
    plot(t,yP);hold on
    plot(t,yPI1);
    plot(t,yPI2);hold off
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',yP,yPI1,yPI2];
    save('step-response-all.txt','d','-ascii');
    
    %% Compute transient response characteristics
    S = stepinfo(yPI2,t);
    sprintf('Ts = %0.2f sec',S.SettlingTime)
end
