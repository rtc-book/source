function root_locus_example_8u(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define system
    G = tf([1],[1,9,26,24]);
    
    %% Compute and save root locus data (and plot)
    figure;
    [r,k] = root_locus_data(G,'root-locus.txt');
    grid on
    
    %% Define the closed-loop transfer function
    K = 31.9;               % from root locus
    GCL = K*G/(1+K*G);      % closed-loop tf (unity feedback)
    
    %% Simulate the step response
    t = linspace(0,5,100);  % time array
    y = step(GCL,t);        % step response simulation
    
    %% Plot step response
    figure
    plot(t,y);
    xlabel('time (s)')
    ylabel('output response')
    
    %% Save step plot data
    d = [t.',y];
    save('step-response.txt','d','-ascii');
    
    %% Compute transient response characteristics
    S = stepinfo(y,t);
    sprintf('OS = %0.1f percent',S.Overshoot)
end
