function root_locus_zv1(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define systems
    sys(:,:,1) = zpk([],[-1,-3],1);
    
    %% Compute and save root locus data (and plot)
    figure;
    filename = ['sys1.txt'];
    [r,k] = root_locus_data(sys(:,:,1),filename);
    xlim([-5,.5])
    ylim([-3,3])
end
