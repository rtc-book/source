function root_locus_zv2(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments

    %% Define systems
    Z = [-5,-4.5,-4,-3.5];
    for n = 1:length(Z)
        sys(:,:,n) = tf([1,-Z(n)],[1,4,3]);
    end
    
    %% Compute and save root locus data (and plot)
    figure;
    for n = 1:length(Z)
        filename = ['sys',num2str(n),'.txt'];
        subplot(4,1,n)
        [r,k] = root_locus_data(sys(:,:,n),filename);
        xlim([-8,1])
        ylim([-3,3])
    end
end
