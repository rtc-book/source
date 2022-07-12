function root_locus_n1(varargin)
    %% Load packages
    addpath('..')               % to load sibling packages
    import plotting.colors.*    % RTCBook colors
    import utils.*              % utilities like root_locus_data function
    colors = plotting.colors(); % ... load them, set as default
    
    %% Parse arguments
%     ts_default = 'T1';              % default elmech system
%     source_default = 'voltage';     % default elmech system
%     variant_default = 'OJ+iL';      % default elmech system
%     p = inputParser;
%     valid_ts = @(x) true;
%     valid_source = @(x) strcmp(x,'voltage'); % has to be voltage source model
%     valid_variant = @(x) true;
%     addParameter(p,'ts',ts_default,valid_ts);
%     addParameter(p,'source',source_default,valid_source);
%     addParameter(p,'variant',variant_default,valid_variant);
%     parse(p,varargin{:});

    %% Define systems
    Z = [-.3,-.7,-1.1,-1.3];
    for k = 1:length(Z)
        sys(:,:,k) = tf([1,-Z(k)],[1,1,0]);
    end
    
    %% Compute and save root locus data (and plot)
    figure;
    for k = 1:length(Z)
        filename = ['sys',num2str(k),'.txt'];
        subplot(1,4,k)
        [r,K] = root_locus_data(sys(:,:,k),filename);
        xlim([-2,.5])
        ylim([-3,3])
    end
end
