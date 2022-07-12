function root_locus_xk(varargin)
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
    zeta = [1.1,1.0,.6,.4];
    Z = [-.2,-.5,-.7,-1.2];
    for n = 1:length(zeta)
        for k = 1:length(Z)
            sys(:,:,n,k) = tf([1,-Z(k)],[1,2*zeta(n),1,0]);
        end
    end
%     sys(:,:,1) = zpk([],[-1,-2],1);
    
    %% Compute and save root locus data (and plot)
    figure;
    for n = 1:length(zeta)
        for k = 1:length(Z)
            filename = ['sys',num2str(n),num2str(k),'.txt'];
            i = k + length(Z)*(n-1);
            disp([n,k,i]);
            subplot(4,4,i)
            [r,k] = root_locus_data(sys(:,:,n,k),filename);
            xlim([-1.6,.5])
            ylim([-3,3])
        end
    end
end
