function root_locus_example_8u(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define system
    sys = tf([1],[1,9,26,24]);
    
    %% Compute and save root locus data (and plot)
    figure;
    filename = ['sys.txt'];
    [r,k] = root_locus_data(sys,filename);
    grid on
end
